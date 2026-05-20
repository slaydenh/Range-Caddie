import Foundation

// MARK: - Facility (user-facing, 4 options)

enum Facility: String, Codable, CaseIterable, Identifiable, Hashable {
    case fullFacility       // range + short game + putting
    case rangeOnly
    case shortGameOnly
    case puttingGreenOnly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullFacility:     return "Full Practice"
        case .rangeOnly:        return "Range"
        case .shortGameOnly:    return "Short Game"
        case .puttingGreenOnly: return "Putting Green"
        }
    }

    var subtitle: String {
        switch self {
        case .fullFacility:     return "Range + short + putting"
        case .rangeOnly:        return "Hitting bays only"
        case .shortGameOnly:    return "Chipping + sand"
        case .puttingGreenOnly: return "Putting only"
        }
    }

    var hasFullSwingArea: Bool {
        self == .fullFacility || self == .rangeOnly
    }
    var hasShortGameArea: Bool {
        self == .fullFacility || self == .shortGameOnly
    }
    var hasPuttingGreen: Bool {
        self == .fullFacility || self == .puttingGreenOnly
    }
}

// MARK: - Club category (internal, 8 values that drills reference)

enum ClubCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case putter
    case wedges          // GW / SW / LW
    case shortIrons      // 9, PW
    case midIrons        // 7, 8
    case longIrons       // 4, 5, 6
    case hybrids
    case fairwayWoods
    case driver

    var id: String { rawValue }
}

// MARK: - Club bucket (user-facing, 4 tiles)

enum ClubBucket: String, Codable, CaseIterable, Identifiable, Hashable {
    case putter
    case wedges
    case irons      // short + mid + long irons
    case driver     // driver + fairway woods + hybrids

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .putter: return "Putter"
        case .wedges: return "Wedges"
        case .irons:  return "Irons"
        case .driver: return "Driver"
        }
    }

    /// The internal club categories this bucket maps to.
    var clubs: Set<ClubCategory> {
        switch self {
        case .putter: return [.putter]
        case .wedges: return [.wedges]
        case .irons:  return [.shortIrons, .midIrons, .longIrons]
        case .driver: return [.driver, .fairwayWoods, .hybrids]
        }
    }

    /// Whether this bucket can be used at the given facility.
    /// (Driver on a putting green doesn't make sense, etc.)
    func fits(at facility: Facility) -> Bool {
        switch self {
        case .putter: return facility.hasPuttingGreen || facility.hasFullSwingArea
        case .wedges: return facility.hasShortGameArea || facility.hasFullSwingArea
        case .irons:  return facility.hasFullSwingArea
        case .driver: return facility.hasFullSwingArea
        }
    }
}

// MARK: - Skill areas (15 areas tracked by the Bayesian model)

enum SkillArea: String, Codable, CaseIterable, Identifiable, Hashable {
    case puttingShort       // ≤6 ft
    case puttingMid         // 6-15 ft
    case puttingLag         // 15+ ft
    case puttingBreak

    case chippingGreenside  // within 20 yd
    case chippingPitch      // 20-50 yd
    case wedgePartial       // 50-100 yd partial wedges

    case ironShort
    case ironMid
    case ironLong

    case woodsHybrid
    case driverAccuracy
    case driverDistance

    case mentalPressure
    case transferRandom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .puttingShort:       return "Short Putting"
        case .puttingMid:         return "Mid Putting"
        case .puttingLag:         return "Lag Putting"
        case .puttingBreak:       return "Breaking Putts"
        case .chippingGreenside:  return "Greenside Chipping"
        case .chippingPitch:      return "Pitching"
        case .wedgePartial:       return "Partial Wedges"
        case .ironShort:          return "Short Irons"
        case .ironMid:            return "Mid Irons"
        case .ironLong:           return "Long Irons"
        case .woodsHybrid:        return "Hybrids / Woods"
        case .driverAccuracy:     return "Driver Accuracy"
        case .driverDistance:     return "Driver Distance"
        case .mentalPressure:     return "Pressure / Closing"
        case .transferRandom:     return "Random / Transfer"
        }
    }

    var facilityRequirement: FacilityZone {
        switch self {
        case .puttingShort, .puttingMid, .puttingLag, .puttingBreak:
            return .putting
        case .chippingGreenside, .chippingPitch:
            return .shortGame
        case .wedgePartial:
            return .shortGameOrRange
        case .ironShort, .ironMid, .ironLong,
             .woodsHybrid, .driverAccuracy, .driverDistance:
            return .range
        case .mentalPressure, .transferRandom:
            return .any
        }
    }
}

enum FacilityZone {
    case putting
    case shortGame
    case shortGameOrRange
    case range
    case any

    func isSupported(by facility: Facility) -> Bool {
        switch self {
        case .putting:           return facility.hasPuttingGreen
        case .shortGame:         return facility.hasShortGameArea
        case .shortGameOrRange:  return facility.hasShortGameArea || facility.hasFullSwingArea
        case .range:             return facility.hasFullSwingArea
        case .any:               return true
        }
    }
}

// MARK: - Session phase

enum SessionPhase: String, Codable, CaseIterable {
    case warmup
    case block        // focused block on a weakness
    case transfer     // random / pressure
    case cooldown

    var displayName: String {
        switch self {
        case .warmup:    return "Warm-up"
        case .block:     return "Focus"
        case .transfer:  return "Pressure"
        case .cooldown:  return "Cool-down"
        }
    }
}

// MARK: - Rating (3-point scale)

enum DrillRating: Int, Codable, CaseIterable, Identifiable {
    case struggled = 1
    case solid     = 3
    case dialed    = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .struggled: return "Struggled"
        case .solid:     return "Solid"
        case .dialed:    return "Dialed"
        }
    }

    var emoji: String {
        switch self {
        case .struggled: return "😬"
        case .solid:     return "👌"
        case .dialed:    return "🔥"
        }
    }

    /// Mapped to a [0, 1] "success fraction" for Bayesian updates.
    var successFraction: Double {
        switch self {
        case .struggled: return 0.10
        case .solid:     return 0.55
        case .dialed:    return 0.92
        }
    }
}
