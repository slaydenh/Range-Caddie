import Foundation
import SwiftData

/// Singleton-ish per-user defaults.
/// Holds the most recent setup choices so the session form can preload them.
@Model
final class UserPreferences {

    @Attribute(.unique) var id: String  // always "default"

    /// Display name shown on the home screen.
    var displayName: String

    /// Last-used facility.
    var lastFacilityRaw: String

    /// Last-used club selection.
    var lastClubsRaw: [String]

    /// Last-used target duration in minutes.
    var lastTargetMinutes: Int

    init(displayName: String = "Golfer",
         lastFacility: Facility = .fullFacility,
         lastClubs: Set<ClubCategory> = [.putter, .wedges, .shortIrons, .midIrons, .driver],
         lastTargetMinutes: Int = 45) {
        self.id = "default"
        self.displayName = displayName
        self.lastFacilityRaw = lastFacility.rawValue
        self.lastClubsRaw = lastClubs.map(\.rawValue).sorted()
        self.lastTargetMinutes = lastTargetMinutes
    }

    var lastFacility: Facility {
        get { Facility(rawValue: lastFacilityRaw) ?? .fullFacility }
        set { lastFacilityRaw = newValue.rawValue }
    }

    var lastClubs: Set<ClubCategory> {
        get { Set(lastClubsRaw.compactMap { ClubCategory(rawValue: $0) }) }
        set { lastClubsRaw = newValue.map(\.rawValue).sorted() }
    }
}
