import Foundation

/// Static drill definition. Drills live in `DrillLibrary` and are looked up by id.
/// Not a SwiftData model — drills are immutable seed content.
struct Drill: Identifiable, Hashable, Codable {

    let id: String
    let name: String
    let summary: String
    let instructions: [String]
    let successCriteria: String

    /// Primary skill areas this drill develops, in order of emphasis.
    let skillAreas: [SkillArea]

    /// Club categories used by the drill.
    let clubs: [ClubCategory]

    /// Default time the drill should take, in minutes.
    let defaultMinutes: Int

    /// Suggested phase placement.
    let suitablePhases: Set<SessionPhase>

    /// Required facility zone (single dimension — derived from primary skill).
    let zone: FacilityZone

    /// 1 = beginner-friendly … 5 = advanced.
    let difficulty: Int

    /// Recommended number of balls / reps.
    let reps: String

    /// Whether the drill is inherently a pressure / closing drill.
    var isPressureDrill: Bool {
        skillAreas.contains(.mentalPressure)
    }

    /// Filter: is this drill possible at the given facility?
    func isPossible(at facility: Facility) -> Bool {
        zone.isSupported(by: facility)
    }

    /// Filter: does the user have at least one club this drill needs?
    func matchesClubs(_ selected: Set<ClubCategory>) -> Bool {
        // Drill is valid if all clubs it needs are selected.
        // For putter-only drills, putter must be selected, etc.
        clubs.allSatisfy { selected.contains($0) }
    }
}
