import Foundation
import SwiftData

/// Builds a structured practice session from the user's inputs plus the
/// learned Bayesian skill model.
///
/// Flow:
///   1. Filter the drill library by facility + selected clubs.
///   2. Sample θ ~ Beta(α, β) per skill area (Thompson sampling).
///      "Need" for a skill is `1 - sampled θ` — weak/uncertain skills score high.
///   3. Score each candidate drill by averaging the need of its target skill
///      areas (with positional weighting).
///   4. Apply recency penalty: drills done in the last 1-2 sessions are
///      down-weighted to avoid repetition fatigue.
///   5. Pack drills into a phase structure that fits the time budget:
///        warmup → focus block (top 1-2 weaknesses) → transfer/pressure → cooldown.
@MainActor
struct SessionGenerator {

    let facility: Facility
    let selectedClubs: Set<ClubCategory>
    let targetMinutes: Int
    let context: ModelContext

    /// Generate the session. Inserts a fresh `PracticeSession` into the context
    /// and returns it (caller must `save`).
    func generate() -> PracticeSession {
        let skillMeans = BayesianModel.currentMeans(in: context)
        let session = PracticeSession(
            facility: facility,
            clubs: selectedClubs,
            targetMinutes: targetMinutes,
            skillMeans: skillMeans
        )
        context.insert(session)

        let plannedDrills = planDrills()
        for (idx, planned) in plannedDrills.enumerated() {
            let record = DrillRecord(
                drillID: planned.drill.id,
                order: idx,
                phase: planned.phase,
                plannedMinutes: planned.minutes
            )
            context.insert(record)
            // SwiftData's inverse relationship populates `session.drills`
            // automatically — don't double-insert by also appending.
            record.session = session
        }
        return session
    }

    // MARK: - Planning

    private struct PlannedDrill {
        let drill: Drill
        let phase: SessionPhase
        let minutes: Int
    }

    private func planDrills() -> [PlannedDrill] {
        // 1. Candidate pool.
        let candidates = DrillLibrary.shared.allDrills
            .filter { $0.isPossible(at: facility) }
            .filter { $0.matchesClubs(selectedClubs) }

        guard !candidates.isEmpty else { return [] }

        // 2. Recent drill ids (last 2 sessions) → recency penalty set.
        let recentDrillIDs = recentlyUsedDrillIDs(within: 2)

        // 3. Compute need per skill area (UCB-style: exploit weakness with a
        //    small exploration bonus from uncertainty).
        var need: [SkillArea: Double] = [:]
        for skill in SkillArea.allCases {
            need[skill] = BayesianModel.need(for: skill, in: context)
        }

        // 4. Zero out need for skills that no candidate drill can train.
        //    Snapshot the keys first — mutating a dict while iterating its `keys`
        //    view is unsafe.
        let trainableSkills = Set(candidates.flatMap(\.skillAreas))
        let toZero = need.keys.filter { !trainableSkills.contains($0) }
        for s in toZero { need[s] = 0.0 }

        // 5. Score every candidate (raw score, before recency penalty).
        func score(_ drill: Drill) -> Double {
            guard !drill.skillAreas.isEmpty else { return 0.0 }
            var total = 0.0
            var weightSum = 0.0
            for (idx, s) in drill.skillAreas.enumerated() {
                let w: Double = (idx == 0) ? 1.0 : (idx == 1 ? 0.6 : 0.4)
                total += w * (need[s] ?? 0.0)
                weightSum += w
            }
            var s = total / weightSum
            // Diversity penalty for very recently used drills.
            if recentDrillIDs.contains(drill.id) { s *= 0.5 }
            return s
        }

        // 6. Determine phase budget.
        let budget = TimeBudget(target: targetMinutes)

        // 7. Pick drills phase-by-phase.
        var picked: [PlannedDrill] = []
        var usedIDs: Set<String> = []

        // --- Warm-up ---
        if let warmup = pickWarmup(from: candidates, excluding: usedIDs, score: score) {
            usedIDs.insert(warmup.id)
            picked.append(PlannedDrill(drill: warmup,
                                       phase: .warmup,
                                       minutes: budget.warmupMinutes))
        }

        // --- Focus blocks ---
        let blockBudget = budget.blockMinutes
        let blockDrills = pickFocusBlocks(from: candidates,
                                          excluding: usedIDs,
                                          score: score,
                                          totalBudget: blockBudget)
        for d in blockDrills {
            usedIDs.insert(d.drill.id)
            picked.append(d)
        }

        // --- Transfer / pressure ---
        if budget.transferMinutes > 0,
           let transfer = pickTransfer(from: candidates,
                                       excluding: usedIDs,
                                       score: score) {
            usedIDs.insert(transfer.id)
            picked.append(PlannedDrill(drill: transfer,
                                       phase: .transfer,
                                       minutes: budget.transferMinutes))
        }

        // --- Cooldown ---
        if let cooldown = pickCooldown(from: candidates,
                                       excluding: usedIDs,
                                       score: score) {
            picked.append(PlannedDrill(drill: cooldown,
                                       phase: .cooldown,
                                       minutes: budget.cooldownMinutes))
        }

        // Final safety: if nothing was picked (very restrictive facility/clubs),
        // fall back to the highest-scoring drill regardless of phase.
        if picked.isEmpty, let fallback = candidates.max(by: { score($0) < score($1) }) {
            picked.append(PlannedDrill(drill: fallback,
                                       phase: .block,
                                       minutes: targetMinutes))
        }
        return picked
    }

    // MARK: - Phase pickers

    private func pickWarmup(from pool: [Drill],
                            excluding used: Set<String>,
                            score: (Drill) -> Double) -> Drill? {
        let warmupPool = pool.filter {
            !used.contains($0.id) &&
            $0.suitablePhases.contains(.warmup) &&
            $0.difficulty <= 3
        }
        // Prefer warmup drills that touch a *moderately* weak skill so we still learn.
        return warmupPool.max(by: { score($0) < score($1) })
            ?? pool.first(where: { $0.suitablePhases.contains(.warmup) })
    }

    private func pickFocusBlocks(from pool: [Drill],
                                 excluding used: Set<String>,
                                 score: (Drill) -> Double,
                                 totalBudget: Int) -> [PlannedDrill] {
        var remaining = totalBudget
        var localUsed = used
        var result: [PlannedDrill] = []

        // Use up to 3 focus drills, each between 8 and 18 minutes.
        let maxBlocks = totalBudget >= 30 ? 3 : (totalBudget >= 18 ? 2 : 1)

        for blockIndex in 0..<maxBlocks {
            guard remaining >= 6 else { break }
            let blockPool = pool.filter {
                !localUsed.contains($0.id) && $0.suitablePhases.contains(.block)
            }
            guard let pick = blockPool.max(by: { score($0) < score($1) }) else { break }

            // Allocate time: first block gets the most.
            let weight: Double
            switch blockIndex {
            case 0:  weight = 0.50
            case 1:  weight = 0.30
            default: weight = 0.20
            }
            var minutes = Int((Double(totalBudget) * weight).rounded())
            minutes = max(6, min(minutes, remaining))
            // Honor drill's own default if it's reasonable.
            if abs(minutes - pick.defaultMinutes) <= 4 {
                minutes = pick.defaultMinutes
                minutes = min(minutes, remaining)
            }
            remaining -= minutes
            localUsed.insert(pick.id)
            result.append(PlannedDrill(drill: pick, phase: .block, minutes: minutes))
        }
        // Donate leftover minutes to the largest block.
        if remaining > 0, !result.isEmpty {
            let idx = result.indices.max(by: { result[$0].minutes < result[$1].minutes }) ?? 0
            let cur = result[idx]
            result[idx] = PlannedDrill(drill: cur.drill,
                                       phase: cur.phase,
                                       minutes: cur.minutes + remaining)
        }
        return result
    }

    private func pickTransfer(from pool: [Drill],
                              excluding used: Set<String>,
                              score: (Drill) -> Double) -> Drill? {
        let transferPool = pool.filter {
            !used.contains($0.id) && $0.suitablePhases.contains(.transfer)
        }
        return transferPool.max(by: { score($0) < score($1) })
    }

    private func pickCooldown(from pool: [Drill],
                              excluding used: Set<String>,
                              score: (Drill) -> Double) -> Drill? {
        let cooldownPool = pool.filter {
            !used.contains($0.id) &&
            $0.suitablePhases.contains(.cooldown) &&
            $0.difficulty <= 3
        }
        return cooldownPool.max(by: { score($0) < score($1) })
            ?? pool.first(where: { $0.suitablePhases.contains(.cooldown) })
    }

    // MARK: - Recency

    private func recentlyUsedDrillIDs(within sessions: Int) -> Set<String> {
        let descriptor = FetchDescriptor<PracticeSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let recent = try? context.fetch(descriptor) else { return [] }
        let slice = recent.prefix(sessions)
        return Set(slice.flatMap { $0.drills.map(\.drillID) })
    }
}

// MARK: - Time budget

/// Splits a target duration into phase budgets.
///
/// Targets (rough percentages):
///   warmup     ≈ 15%   (min 5, max 10)
///   focus block≈ 55%
///   transfer   ≈ 20%   (omitted on short sessions)
///   cooldown   ≈ 10%   (min 3, max 6)
struct TimeBudget {
    let target: Int
    let warmupMinutes: Int
    let blockMinutes: Int
    let transferMinutes: Int
    let cooldownMinutes: Int

    init(target: Int) {
        self.target = target
        let t = Double(target)

        // Warm-up
        let warm = max(5, min(Int((t * 0.15).rounded()), 10))

        // Cool-down — only if session is 35+ minutes
        let cool: Int = target >= 35 ? max(3, min(Int((t * 0.10).rounded()), 6)) : 0

        // Transfer — only if session is 40+ minutes
        let transfer: Int = target >= 40 ? max(5, min(Int((t * 0.20).rounded()), 12)) : 0

        // Block gets the rest.
        let block = max(10, target - warm - cool - transfer)

        self.warmupMinutes = warm
        self.blockMinutes = block
        self.transferMinutes = transfer
        self.cooldownMinutes = cool
    }
}
