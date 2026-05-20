import Foundation
import SwiftData

/// A single drill *instance* inside a `PracticeSession`.
/// Stores the plan (which drill, how long, what phase) and the outcome
/// (rating, notes, when it was completed).
@Model
final class DrillRecord {

    @Attribute(.unique) var id: UUID

    /// Foreign reference to the static `Drill` in the seed library.
    var drillID: String

    /// Order within its parent session.
    var order: Int

    /// Planned phase placement.
    var phaseRaw: String

    /// Planned time in minutes.
    var plannedMinutes: Int

    /// Outcome — nil until the user rates the drill.
    var ratingRaw: Int?
    var notes: String

    /// When the user marked the drill complete.
    var completedAt: Date?

    /// Backpointer to the session — SwiftData fills this via inverse relationship.
    var session: PracticeSession?

    init(drillID: String,
         order: Int,
         phase: SessionPhase,
         plannedMinutes: Int) {
        self.id = UUID()
        self.drillID = drillID
        self.order = order
        self.phaseRaw = phase.rawValue
        self.plannedMinutes = plannedMinutes
        self.notes = ""
    }

    var phase: SessionPhase {
        SessionPhase(rawValue: phaseRaw) ?? .block
    }

    var rating: DrillRating? {
        guard let r = ratingRaw else { return nil }
        return DrillRating(rawValue: r)
    }

    /// Resolve the static drill definition from the library.
    var drill: Drill? {
        DrillLibrary.shared.drill(for: drillID)
    }
}
