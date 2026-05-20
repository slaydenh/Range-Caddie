import Foundation
import SwiftData

/// Singleton-ish per-user defaults so the setup form preloads with the last picks.
@Model
final class UserPreferences {

    @Attribute(.unique) var id: String  // always "default"

    var lastFacilityRaw: String
    var lastClubBucketsRaw: [String]
    var lastTargetMinutes: Int

    init(lastFacility: Facility = .fullFacility,
         lastClubBuckets: Set<ClubBucket> = [.putter, .wedges, .irons, .driver],
         lastTargetMinutes: Int = 45) {
        self.id = "default"
        self.lastFacilityRaw = lastFacility.rawValue
        self.lastClubBucketsRaw = lastClubBuckets.map(\.rawValue).sorted()
        self.lastTargetMinutes = lastTargetMinutes
    }

    var lastFacility: Facility {
        get { Facility(rawValue: lastFacilityRaw) ?? .fullFacility }
        set { lastFacilityRaw = newValue.rawValue }
    }

    var lastClubBuckets: Set<ClubBucket> {
        get { Set(lastClubBucketsRaw.compactMap { ClubBucket(rawValue: $0) }) }
        set { lastClubBucketsRaw = newValue.map(\.rawValue).sorted() }
    }
}
