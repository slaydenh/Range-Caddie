import Foundation
import SwiftData

/// Persistent Beta(α, β) posterior for a single `SkillArea`.
///
/// Mean = α / (α + β) is the model's current estimate of mastery in [0, 1].
/// Higher mean → user is competent → drill is less needed.
/// Lower mean  → user is weak     → drill is more needed.
///
/// We also track `lastUpdated` and `observationCount` to implement
/// gentle time-decay so old data fades when the user comes back later.
@Model
final class SkillState {

    /// Stored as raw string so SwiftData can persist it cleanly.
    @Attribute(.unique) var skillRaw: String

    /// Beta(α, β) hyperparameters.
    var alpha: Double
    var beta: Double

    /// How many drill ratings have updated this skill.
    var observationCount: Int

    /// Last time this skill was updated.
    var lastUpdated: Date

    init(skill: SkillArea,
         alpha: Double = 2.0,
         beta: Double = 2.0,
         observationCount: Int = 0,
         lastUpdated: Date = .distantPast) {
        self.skillRaw = skill.rawValue
        self.alpha = alpha
        self.beta = beta
        self.observationCount = observationCount
        self.lastUpdated = lastUpdated
    }

    var skill: SkillArea {
        SkillArea(rawValue: skillRaw) ?? .transferRandom
    }

    /// Posterior mean of mastery in [0, 1].
    var mean: Double {
        let denom = alpha + beta
        guard denom > 0 else { return 0.5 }
        return alpha / denom
    }

    /// Posterior variance — proxy for our uncertainty.
    var variance: Double {
        let s = alpha + beta
        guard s > 1 else { return 0.25 }
        return (alpha * beta) / (s * s * (s + 1))
    }

    /// Standard deviation, useful for UI.
    var stddev: Double { variance.squareRoot() }

    /// Days since this skill was last updated.
    var daysSinceUpdate: Double {
        guard lastUpdated != .distantPast else { return .infinity }
        return Date().timeIntervalSince(lastUpdated) / 86_400.0
    }
}
