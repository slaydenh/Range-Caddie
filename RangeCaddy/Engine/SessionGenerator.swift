import Foundation
import SwiftData

/// Builds a structured practice session from the user's inputs plus the
/// learned Bayesian skill model.
///
/// Flow:
///   1. Filter the drill library by facility + selected clubs.
///   2. Compute per-skill "need" via `BayesianModel.need(for:in:)`
///      (UCB-style: weakness + small exploration bonus).
///   3. Score each candidate drill against current need, with a recency
///      penalty for drills used in the last two sessions.
///   4. Pack into phases (warmup → focus blocks → transfer → cooldown).
///   5. Donate unused phase budget back to the biggest focus block so the
///      total time always matches what the user asked for.
@MainActor
struct SessionGenerator {

    let facility: Facility
    let selectedBuckets: Set<ClubBucket>
    let targetMinutes: Int
    let context: ModelContext

    /// Generate the session and insert it into the context. Caller must `save`.
    func generate() -> PracticeSession {
        let session = PracticeSession(
            facility: facility,
            clubBuckets: selectedBuckets,
            targetMinutes: targetMinutes
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
            record.session = session
        }
        return session
    }

    // MARK: - Planning

    private struct PlannedDrill {
        let drill: Drill
        let phase: SessionPhase
        var minutes: Int
    }

    /// Expanded set of internal club categories the user has available.
    private var expandedClubs: Set<ClubCategory> {
        var out: Set<ClubCategory> = []
        for bucket in selectedBuckets { out.formUnion(bucket.clubs) }
        return out
    }

    private func planDrills() -> [PlannedDrill] {
        let clubs = expandedClubs

        // 1. Candidate pool.
        let candidates = DrillLibrary.shared.allDrills
            .filter { $0.isPossible(at: facility) }
            .filter { $0.matchesClubs(clubs) }

        guard !candidates.isEmpty else { return [] }

        // 2. Recent drill ids (last 2 sessions) → recency penalty set.
        let recentDrillIDs = recentlyUsedDrillIDs(within: 2)

        // 3. Need per skill area.
        var need: [SkillArea: Double] = [:]
        for skill in SkillArea.allCases {
            need[skill] = BayesianModel.need(for: skill, in: context)
        }

        // 4. Zero out skills no candidate can train.
        let trainableSkills = Set(candidates.flatMap(\.skillAreas))
        let toZero = need.keys.filter { !trainableSkills.contains($0) }
        for s in toZero { need[s] = 0.0 }

        // 5. Score every candidate.
        func score(_ drill: Drill) -> Double {
            guard !drill.skillAreas.isEmpty else { return 0.0 }
            var total = 0.0
            var weightSum = 0.0
            for (idx, s) in drill.skillAreas.enumerated() {
                let w: Double = (idx == 0) ? 1.0 : (idx == 1 ? 0.6 : 0.4)
                total += w * (need[s] ?? 0.0)
                weightSum += w
            }
            var raw = total / weightSum
            if recentDrillIDs.contains(drill.id) { raw *= 0.5 }
            return raw
        }

        func bestPick(from pool: [Drill]) -> Drill? {
            pool.max(by: { score($0) < score($1) })
        }

        // 6. Phase budget.
        let budget = TimeBudget(target: targetMinutes)
        var leftoverFromOptional = 0

        // 7. Pick phase-by-phase.
        var picked: [PlannedDrill] = []
        var blocks: [Int] = []  // indices into `picked` of block entries
        var usedIDs: Set<String> = []

        // --- Warm-up ---
        let warmupPool = candidates.filter {
            !usedIDs.contains($0.id) && $0.suitablePhases.contains(.warmup)
        }
        if let warmup = bestPick(from: warmupPool) {
            usedIDs.insert(warmup.id)
            picked.append(PlannedDrill(drill: warmup,
                                       phase: .warmup,
                                       minutes: budget.warmupMinutes))
        } else {
            leftoverFromOptional += budget.warmupMinutes
        }

        // --- Focus blocks ---
        let maxBlocks = targetMinutes >= 30 ? 3 : 2
        var remaining = budget.blockMinutes
        for i in 0..<maxBlocks {
            guard remaining >= 6 else { break }
            let blockPool = candidates.filter {
                !usedIDs.contains($0.id) && $0.suitablePhases.contains(.block)
            }
            guard let pick = bestPick(from: blockPool) else { break }
            let weight: Double
            switch i {
            case 0:  weight = 0.50
            case 1:  weight = 0.30
            default: weight = 0.20
            }
            var minutes = Int((Double(budget.blockMinutes) * weight).rounded())
            minutes = max(6, min(minutes, remaining))
            if abs(minutes - pick.defaultMinutes) <= 4 {
                minutes = min(pick.defaultMinutes, remaining)
            }
            remaining -= minutes
            usedIDs.insert(pick.id)
            picked.append(PlannedDrill(drill: pick, phase: .block, minutes: minutes))
            blocks.append(picked.count - 1)
        }
        // Donate leftover block minutes to the largest block.
        if remaining > 0, !blocks.isEmpty {
            let biggest = blocks.max(by: { picked[$0].minutes < picked[$1].minutes })!
            picked[biggest].minutes += remaining
        }

        // --- Transfer ---
        if budget.transferMinutes > 0 {
            let transferPool = candidates.filter {
                !usedIDs.contains($0.id) && $0.suitablePhases.contains(.transfer)
            }
            if let t = bestPick(from: transferPool) {
                usedIDs.insert(t.id)
                picked.append(PlannedDrill(drill: t,
                                           phase: .transfer,
                                           minutes: budget.transferMinutes))
            } else {
                leftoverFromOptional += budget.transferMinutes
            }
        }

        // --- Cool-down ---
        if budget.cooldownMinutes > 0 {
            let cooldownPool = candidates.filter {
                !usedIDs.contains($0.id) && $0.suitablePhases.contains(.cooldown)
            }
            if let c = bestPick(from: cooldownPool) {
                picked.append(PlannedDrill(drill: c,
                                           phase: .cooldown,
                                           minutes: budget.cooldownMinutes))
            } else {
                leftoverFromOptional += budget.cooldownMinutes
            }
        }

        // 8. Donate any unused warm-up / transfer / cool-down minutes back to
        //    the biggest focus block so the user gets the full session length.
        if leftoverFromOptional > 0, !blocks.isEmpty {
            let biggest = blocks.max(by: { picked[$0].minutes < picked[$1].minutes })!
            picked[biggest].minutes += leftoverFromOptional
        }

        // Safety fallback if nothing matched.
        if picked.isEmpty, let fallback = bestPick(from: candidates) {
            picked.append(PlannedDrill(drill: fallback,
                                       phase: .block,
                                       minutes: targetMinutes))
        }
        return picked
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

struct TimeBudget {
    let target: Int
    let warmupMinutes: Int
    let blockMinutes: Int
    let transferMinutes: Int
    let cooldownMinutes: Int

    init(target: Int) {
        self.target = target
        let t = Double(target)

        let warm = max(5, min(Int((t * 0.15).rounded()), 10))
        let cool: Int = target >= 35 ? max(3, min(Int((t * 0.10).rounded()), 6)) : 0
        let transfer: Int = target >= 40 ? max(5, min(Int((t * 0.20).rounded()), 12)) : 0
        let block = max(10, target - warm - cool - transfer)

        self.warmupMinutes = warm
        self.blockMinutes = block
        self.transferMinutes = transfer
        self.cooldownMinutes = cool
    }
}
