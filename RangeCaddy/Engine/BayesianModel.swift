import Foundation
import SwiftData

/// Conjugate Beta-Binomial skill tracker.
///
/// Each `SkillArea` has a Beta(α, β) posterior over a hidden mastery
/// parameter θ ∈ [0, 1]. A drill rating contributes a fractional success
/// observation `r ∈ [0, 1]` (see `DrillRating.successFraction`) with an
/// "effective sample size" `n` (= weight × confidence in the drill).
///
/// Update rule (treating r as expected successes from n trials):
///     α' = α + n * r
///     β' = β + n * (1 - r)
///
/// Before each update we apply a gentle time-decay so the model is
/// responsive to recent change but doesn't forget everything.
@MainActor
struct BayesianModel {

    /// Effective sample size per drill rating. Higher = each rating moves the
    /// estimate more; lower = the model is slower & more conservative.
    static let baseObservationWeight: Double = 2.0

    /// Half-life in days. After this many days, the equivalent prior strength
    /// is halved (mean is pulled toward the neutral prior).
    static let decayHalfLifeDays: Double = 30.0

    /// Neutral prior strength we decay toward.
    static let neutralAlpha: Double = 2.0
    static let neutralBeta: Double = 2.0

    // MARK: - Read

    /// Pure-lookup: returns the persisted SkillState if it exists, otherwise nil.
    /// Safe to call from SwiftUI view bodies — never mutates the context.
    static func existingState(for skill: SkillArea, in context: ModelContext) -> SkillState? {
        let raw = skill.rawValue
        let descriptor = FetchDescriptor<SkillState>(
            predicate: #Predicate { $0.skillRaw == raw }
        )
        return try? context.fetch(descriptor).first
    }

    /// Get-or-create. Only call from event handlers (button taps, save flows).
    /// Will insert a new SkillState into the context if none exists.
    static func ensureState(for skill: SkillArea, in context: ModelContext) -> SkillState {
        if let existing = existingState(for: skill, in: context) { return existing }
        let new = SkillState(skill: skill)
        context.insert(new)
        return new
    }

    /// Snapshot of posterior means across every skill area. Read-only.
    /// Skills with no data are reported at the neutral prior mean (0.5).
    static func currentMeans(in context: ModelContext) -> [SkillArea: Double] {
        var out: [SkillArea: Double] = [:]
        for s in SkillArea.allCases {
            out[s] = existingState(for: s, in: context)?.mean ?? 0.5
        }
        return out
    }

    // MARK: - Update

    /// Apply a rating from a single drill back into every skill the drill targets.
    ///
    /// - Parameters:
    ///   - rating: the user's 1-5 outcome.
    ///   - drill:  the static drill definition.
    ///   - difficulty: drill difficulty (1-5). Harder drills slightly amplify weight.
    static func applyRating(_ rating: DrillRating,
                            for drill: Drill,
                            in context: ModelContext) {
        for (idx, skill) in drill.skillAreas.enumerated() {
            // Primary skills get full weight; secondary skills get reduced weight.
            let positionalWeight: Double
            switch idx {
            case 0:  positionalWeight = 1.0
            case 1:  positionalWeight = 0.6
            default: positionalWeight = 0.4
            }
            // Harder drills count slightly more (0.9 … 1.3).
            let difficultyBoost = 0.8 + 0.1 * Double(drill.difficulty)
            let n = baseObservationWeight * positionalWeight * difficultyBoost
            applyObservation(rating.successFraction,
                             weight: n,
                             to: skill,
                             in: context)
        }
    }

    /// Apply a single fractional observation to a skill, with time-decay first.
    private static func applyObservation(_ successFraction: Double,
                                         weight n: Double,
                                         to skill: SkillArea,
                                         in context: ModelContext) {
        let st = ensureState(for: skill, in: context)
        decayInPlace(st)
        st.alpha += n * successFraction
        st.beta  += n * (1.0 - successFraction)
        st.observationCount += 1
        st.lastUpdated = Date()
    }

    /// Pull the posterior gently toward the neutral prior based on elapsed days.
    private static func decayInPlace(_ st: SkillState) {
        guard st.lastUpdated != .distantPast else { return }
        let days = st.daysSinceUpdate
        guard days > 0 else { return }

        // Decay factor in (0, 1]. After `decayHalfLifeDays`, factor = 0.5.
        let factor = pow(0.5, days / decayHalfLifeDays)

        // Move (α - neutralAlpha) and (β - neutralBeta) toward 0 by `factor`.
        let aOffset = st.alpha - neutralAlpha
        let bOffset = st.beta  - neutralBeta
        st.alpha = neutralAlpha + aOffset * factor
        st.beta  = neutralBeta  + bOffset * factor
    }

    // MARK: - Thompson sampling

    /// Sample θ ~ Beta(α, β) for a skill.
    /// Kept around for callers that want raw exploration; the session generator
    /// uses `need(for:in:)` below for predictable user-facing behavior.
    static func sampleTheta(for skill: SkillArea, in context: ModelContext) -> Double {
        if let st = existingState(for: skill, in: context) {
            return BetaSampler.sample(alpha: st.alpha, beta: st.beta)
        }
        return BetaSampler.sample(alpha: neutralAlpha, beta: neutralBeta)
    }

    // MARK: - Need score

    /// Per-skill "need" used by the session planner.
    /// Deterministic-leaning: mostly `1 - mean` (exploit known weaknesses),
    /// plus a small bonus from posterior stddev (probe uncertain skills) and
    /// tiny noise for tie-breaking. This matches user intuition — when you
    /// rate a drill poorly, you should see more of that area next session.
    static func need(for skill: SkillArea, in context: ModelContext) -> Double {
        let mean: Double
        let sd: Double
        if let st = existingState(for: skill, in: context) {
            mean = st.mean
            sd = st.stddev
        } else {
            // Neutral prior — Beta(2, 2): mean=0.5, sd ≈ 0.224
            mean = 0.5
            sd = 0.224
        }
        let noise = (Double.random(in: 0...1) - 0.5) * 0.04
        return max(0.0, (1.0 - mean) + 0.2 * sd + noise)
    }
}

// MARK: - Beta sampler

/// Draws samples from Beta(α, β) using the standard trick:
///   X = G1 / (G1 + G2)
/// where Gi ~ Gamma(αi, 1), and we sample Gamma via Marsaglia-Tsang.
enum BetaSampler {

    static func sample(alpha: Double, beta: Double) -> Double {
        let safeA = max(alpha, 1e-6)
        let safeB = max(beta,  1e-6)
        let x = gamma(shape: safeA)
        let y = gamma(shape: safeB)
        let denom = x + y
        guard denom > 0 else { return 0.5 }
        return x / denom
    }

    /// Marsaglia & Tsang's method for Gamma(shape, 1). Works for shape ≥ 1.
    /// For shape < 1, use Johnk's algorithm via the boost trick:
    ///     G(α) =d= G(α + 1) * U^(1/α)
    private static func gamma(shape: Double) -> Double {
        if shape < 1.0 {
            let u = Double.random(in: 1e-12 ... 1.0)
            return gamma(shape: shape + 1.0) * pow(u, 1.0 / shape)
        }
        let d = shape - 1.0 / 3.0
        let c = 1.0 / sqrt(9.0 * d)
        while true {
            let x = standardNormal()
            let v = pow(1.0 + c * x, 3)
            if v <= 0 { continue }
            let u = Double.random(in: 1e-12 ... 1.0)
            let x2 = x * x
            if u < 1.0 - 0.0331 * x2 * x2 {
                return d * v
            }
            if log(u) < 0.5 * x2 + d * (1.0 - v + log(v)) {
                return d * v
            }
        }
    }

    /// Box-Muller standard normal.
    private static func standardNormal() -> Double {
        let u1 = Double.random(in: 1e-12 ... 1.0)
        let u2 = Double.random(in: 0.0 ... 1.0)
        return sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
    }
}
