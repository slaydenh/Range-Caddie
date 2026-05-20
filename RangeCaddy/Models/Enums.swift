import Foundation

// MARK: - Club Categories
// Coarse buckets the user selects when setting up a session.

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

    var displayName: String {
        switch self {
        case .putter:        return "Putter"
        case .wedges:        return "Wedges"
        case .shortIrons:    return "Short Irons"
        case .midIrons:      return "Mid Irons"
        case .longIrons:     return "Long Irons"
        case .hybrids:       return "Hybrids"
        case .fairwayWoods:  return "Fairway Woods"
        case .driver:        return "Driver"
        }
    }

    var symbolName: String {
        switch self {
        case .putter:        return "circle.dotted"
        case .wedges:        return "leaf"
        case .shortIrons:    return "target"
        case .midIrons:      return "scope"
        case .longIrons:     return "arrow.up.right"
        case .hybrids:       return "arrow.triangle.merge"
        case .fairwayWoods:  return "arrow.up.forward"
        case .driver:        return "bolt"
        }
    }
}

// MARK: - Facilities
// Where the user is practicing. Affects which drills are feasible.

enum Facility: String, Codable, CaseIterable, Identifiable, Hashable {
    case fullFacility       // range + short game + putting green
    case rangeShortGame     // range + short game, no putting
    case rangePutting       // range + putting green, no short game
    case rangeOnly          // hitting bays only
    case shortGameOnly
    case puttingGreenOnly
    case simulator
    case home               // mat, putting indoor, net

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullFacility:     return "Full Practice Facility"
        case .rangeShortGame:   return "Range + Short Game"
        case .rangePutting:     return "Range + Putting Green"
        case .rangeOnly:        return "Driving Range Only"
        case .shortGameOnly:    return "Short Game Area"
        case .puttingGreenOnly: return "Putting Green"
        case .simulator:        return "Simulator / Indoor"
        case .home:             return "Home / Mat"
        }
    }

    var symbolName: String {
        switch self {
        case .fullFacility:     return "star.circle"
        case .rangeShortGame:   return "flag.2.crossed"
        case .rangePutting:     return "flag.checkered"
        case .rangeOnly:        return "figure.golf"
        case .shortGameOnly:    return "leaf.circle"
        case .puttingGreenOnly: return "circle.dotted"
        case .simulator:        return "tv"
        case .home:             return "house"
        }
    }

    /// Whether this facility supports a given practice zone.
    var hasFullSwingArea: Bool {
        switch self {
        case .fullFacility, .rangeShortGame, .rangePutting, .rangeOnly, .simulator, .home:
            return true
        case .shortGameOnly, .puttingGreenOnly:
            return false
        }
    }

    var hasShortGameArea: Bool {
        switch self {
        case .fullFacility, .rangeShortGame, .shortGameOnly:
            return true
        case .simulator:
            return true     // many sims have short game
        case .home:
            return true     // chip net counts
        case .rangePutting, .rangeOnly, .puttingGreenOnly:
            return false
        }
    }

    var hasPuttingGreen: Bool {
        switch self {
        case .fullFacility, .rangePutting, .puttingGreenOnly, .home, .simulator:
            return true
        case .rangeShortGame, .rangeOnly, .shortGameOnly:
            return false
        }
    }
}

// MARK: - Skill Areas
// Granular skills tracked by the Bayesian model.

enum SkillArea: String, Codable, CaseIterable, Identifiable, Hashable {
    case puttingShort       // ≤6 ft
    case puttingMid         // 6-15 ft
    case puttingLag         // 15+ ft
    case puttingBreak       // breaking putts / reads

    case chippingGreenside  // within 20 yd, low
    case chippingPitch      // 20-50 yd
    case wedgePartial       // 50-100 yd partial wedges

    case ironShort          // PW / 9
    case ironMid            // 7 / 8
    case ironLong           // 4 / 5 / 6

    case woodsHybrid        // hybrids + fairway woods

    case driverAccuracy
    case driverDistance

    case mentalPressure     // closing under pressure
    case transferRandom     // random / mixed shots

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

    /// Which club categories enable practicing this skill.
    var relevantClubs: Set<ClubCategory> {
        switch self {
        case .puttingShort, .puttingMid, .puttingLag, .puttingBreak:
            return [.putter]
        case .chippingGreenside:
            return [.wedges, .shortIrons]
        case .chippingPitch:
            return [.wedges]
        case .wedgePartial:
            return [.wedges]
        case .ironShort:
            return [.shortIrons]
        case .ironMid:
            return [.midIrons]
        case .ironLong:
            return [.longIrons]
        case .woodsHybrid:
            return [.hybrids, .fairwayWoods]
        case .driverAccuracy, .driverDistance:
            return [.driver]
        case .mentalPressure, .transferRandom:
            // pressure & transfer can be practiced with anything
            return Set(ClubCategory.allCases)
        }
    }

    /// Which facility zone is required.
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

// MARK: - Session Phase
// The flow of a practice session.

enum SessionPhase: String, Codable, CaseIterable {
    case warmup
    case block            // focused block on a weakness
    case transfer         // random / pressure
    case cooldown

    var displayName: String {
        switch self {
        case .warmup:    return "Warm-up"
        case .block:     return "Focus Block"
        case .transfer:  return "Transfer / Pressure"
        case .cooldown:  return "Cool-down"
        }
    }

    var symbolName: String {
        switch self {
        case .warmup:    return "flame"
        case .block:     return "scope"
        case .transfer:  return "shuffle"
        case .cooldown:  return "leaf"
        }
    }
}

// MARK: - Rating
// User's self-assessment after a drill.

enum DrillRating: Int, Codable, CaseIterable, Identifiable {
    case poor = 1
    case belowAverage = 2
    case average = 3
    case good = 4
    case excellent = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .poor:          return "Poor"
        case .belowAverage:  return "Below"
        case .average:       return "Average"
        case .good:          return "Good"
        case .excellent:     return "Excellent"
        }
    }

    var symbolName: String {
        switch self {
        case .poor:          return "xmark.circle.fill"
        case .belowAverage:  return "minus.circle.fill"
        case .average:       return "equal.circle.fill"
        case .good:          return "checkmark.circle.fill"
        case .excellent:     return "star.circle.fill"
        }
    }

    /// Mapped to a [0,1] "success fraction" for Bayesian updates.
    /// 1 = perfect execution, 0 = total failure.
    var successFraction: Double {
        switch self {
        case .poor:          return 0.10
        case .belowAverage:  return 0.30
        case .average:       return 0.55
        case .good:          return 0.75
        case .excellent:     return 0.92
        }
    }
}
