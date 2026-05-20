import Foundation

/// Curated seed library of practice drills.
/// IDs are stable strings — never rename in place once a drill ships.
final class DrillLibrary {

    static let shared = DrillLibrary()

    let allDrills: [Drill]
    private let byID: [String: Drill]

    private init() {
        self.allDrills = DrillLibrary.seed
        self.byID = Dictionary(uniqueKeysWithValues: DrillLibrary.seed.map { ($0.id, $0) })
    }

    func drill(for id: String) -> Drill? {
        byID[id]
    }
}

private extension DrillLibrary {

    static let seed: [Drill] = [

        // ───────────────────────────────────────────────
        // MARK: Putting
        // ───────────────────────────────────────────────
        Drill(
            id: "putt.gate.3ft",
            name: "Gate Drill — 3 ft",
            summary: "Push 3-foot putts through a narrow tee gate to dial in face control.",
            instructions: [
                "Set two tees just wider than your putter head, 3 ft from a flat hole.",
                "Place a ball 3 ft from the cup, on the line through the gate.",
                "Make 10 putts in a row through the gate, into the cup.",
                "Reset to zero if a putt misses the gate or the cup."
            ],
            successCriteria: "10 in a row through the gate AND into the hole.",
            skillAreas: [.puttingShort],
            clubs: [.putter],
            defaultMinutes: 8,
            suitablePhases: [.warmup, .block, .cooldown],
            zone: .putting,
            difficulty: 2,
            reps: "Until you can chain 10"
        ),

        Drill(
            id: "putt.clock.3ft",
            name: "Clock Drill",
            summary: "Six 3-foot putts around the hole. Miss one and restart.",
            instructions: [
                "Place six balls evenly around the hole at 3 ft (12, 2, 4, 6, 8, 10 o'clock).",
                "Hole each ball in order without missing.",
                "If you miss, reset all six and start again."
            ],
            successCriteria: "Clear the clock without a miss.",
            skillAreas: [.puttingShort, .mentalPressure],
            clubs: [.putter],
            defaultMinutes: 10,
            suitablePhases: [.block, .transfer],
            zone: .putting,
            difficulty: 3,
            reps: "Up to 3 clean rounds"
        ),

        Drill(
            id: "putt.ladder",
            name: "Distance Ladder",
            summary: "Lag to 10, 20, 30, 40 ft targets — distance control without a hole.",
            instructions: [
                "Drop tees as targets at 10, 20, 30, and 40 feet on a flat stretch of green.",
                "Hit one ball to each target, in order, then back down.",
                "Score: inside 1 putter length = 2 pts, inside 3 ft = 1 pt."
            ],
            successCriteria: "Score 12+ over 8 putts (4 up, 4 down).",
            skillAreas: [.puttingLag, .puttingMid],
            clubs: [.putter],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .putting,
            difficulty: 2,
            reps: "2-3 sets of 8"
        ),

        Drill(
            id: "putt.9ball",
            name: "9-Ball Test",
            summary: "3 balls each from 3, 6, and 9 feet. Make as many as possible.",
            instructions: [
                "Find a fairly straight putt.",
                "Hit 3 from 3 ft, 3 from 6 ft, 3 from 9 ft.",
                "Track your make total each round."
            ],
            successCriteria: "Make 7 of 9 to pass.",
            skillAreas: [.puttingShort, .puttingMid],
            clubs: [.putter],
            defaultMinutes: 10,
            suitablePhases: [.block, .transfer],
            zone: .putting,
            difficulty: 3,
            reps: "3 rounds"
        ),

        Drill(
            id: "putt.break.read",
            name: "Read & Roll",
            summary: "Read a breaking putt, commit, hit. Build trust on slope.",
            instructions: [
                "Find a 10-15 ft breaking putt.",
                "Read from low side. Pick an apex. Commit.",
                "Hit 3 balls from the same spot. Reset and pick a new break.",
                "Aim to start every ball on your chosen line."
            ],
            successCriteria: "All 3 balls start on the chosen line; majority finish inside 18 inches.",
            skillAreas: [.puttingBreak, .puttingMid],
            clubs: [.putter],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .putting,
            difficulty: 4,
            reps: "5 different breaks"
        ),

        Drill(
            id: "putt.eyesclosed",
            name: "Eyes-Closed Feel",
            summary: "Roll 15-foot putts with eyes closed to build internal distance feel.",
            instructions: [
                "Pick a 15 ft target on a flat section.",
                "Take your stance, look at the target, close your eyes.",
                "Make the stroke with eyes closed.",
                "Open eyes only after the putt is rolling. Adjust feel, not mechanics."
            ],
            successCriteria: "Average finish inside a 3 ft circle on 10 putts.",
            skillAreas: [.puttingLag],
            clubs: [.putter],
            defaultMinutes: 8,
            suitablePhases: [.warmup, .cooldown],
            zone: .putting,
            difficulty: 2,
            reps: "10 putts"
        ),

        Drill(
            id: "putt.onehanded",
            name: "One-Handed Putts",
            summary: "Six-foot putts with the trail hand only — exposes face control issues.",
            instructions: [
                "Use only your trail hand on the grip (right hand for right-handers).",
                "Hit 10 putts from 6 ft to a flat hole.",
                "Focus on stable wrist and on-center contact."
            ],
            successCriteria: "Make 5 of 10.",
            skillAreas: [.puttingShort, .puttingMid],
            clubs: [.putter],
            defaultMinutes: 6,
            suitablePhases: [.warmup, .block],
            zone: .putting,
            difficulty: 3,
            reps: "10 putts"
        ),

        Drill(
            id: "putt.lag.funnel",
            name: "Lag Funnel",
            summary: "Long putts must finish inside a 3-foot circle around the hole.",
            instructions: [
                "Mark a 3 ft circle around a hole with tees (or eyeball it).",
                "Hit 6 putts from 30 ft. Then 6 from 40 ft. Then 6 from 50 ft.",
                "Goal: get every ball into the circle."
            ],
            successCriteria: "≥14/18 in the circle.",
            skillAreas: [.puttingLag],
            clubs: [.putter],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .putting,
            difficulty: 3,
            reps: "18 putts"
        ),

        Drill(
            id: "putt.holehigh.5ft",
            name: "Hole-High 5-Footers",
            summary: "Roll every 5-foot putt past the hole on the right line.",
            instructions: [
                "Pick a flat 5 ft putt.",
                "Every ball must reach the hole — short doesn't count.",
                "10 putts. Track makes."
            ],
            successCriteria: "Make 7 of 10.",
            skillAreas: [.puttingShort, .mentalPressure],
            clubs: [.putter],
            defaultMinutes: 6,
            suitablePhases: [.block, .transfer],
            zone: .putting,
            difficulty: 3,
            reps: "10 putts"
        ),

        Drill(
            id: "putt.chip.combo",
            name: "Chip-Then-Putt",
            summary: "Chip one, putt out. Repeat. Forces you to commit to the first putt.",
            instructions: [
                "From off the green, chip one ball at a hole.",
                "Wherever it stops, putt it out (no marker).",
                "Track 'up & downs' — got it in 2 shots? Pass.",
                "Repeat 8 times from different lies."
            ],
            successCriteria: "5 of 8 up & down.",
            skillAreas: [.transferRandom, .chippingGreenside, .puttingShort],
            clubs: [.wedges, .putter],
            defaultMinutes: 12,
            suitablePhases: [.transfer],
            zone: .shortGame,
            difficulty: 3,
            reps: "8 attempts"
        ),

        // ───────────────────────────────────────────────
        // MARK: Chipping & Pitching
        // ───────────────────────────────────────────────
        Drill(
            id: "chip.landingpad",
            name: "Landing Pad",
            summary: "Land every chip on a towel — landing-spot control.",
            instructions: [
                "Lay a towel on the green about 1/3 of the way to the hole.",
                "Chip 10 balls trying to land each one on the towel.",
                "Count any ball that lands on or touches the towel as a hit."
            ],
            successCriteria: "6 of 10 hits.",
            skillAreas: [.chippingGreenside],
            clubs: [.wedges],
            defaultMinutes: 8,
            suitablePhases: [.warmup, .block],
            zone: .shortGame,
            difficulty: 2,
            reps: "10 chips"
        ),

        Drill(
            id: "chip.highlow",
            name: "High-Low Wedge",
            summary: "Same target, two trajectories — PW low check vs LW high stop.",
            instructions: [
                "Pick a target hole about 15 yd away.",
                "Hit 5 low bump-and-runs with a PW.",
                "Hit 5 high soft chips with your LW.",
                "Notice landing spot, total roll, stop pattern."
            ],
            successCriteria: "All 10 finish inside 6 ft.",
            skillAreas: [.chippingGreenside],
            clubs: [.wedges, .shortIrons],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .shortGame,
            difficulty: 3,
            reps: "10 chips"
        ),

        Drill(
            id: "chip.bumprun.7i",
            name: "Bump-and-Run 7i",
            summary: "Use a 7-iron from the fringe — low, predictable rollers.",
            instructions: [
                "From the fringe with at least 30 ft to the hole, use a 7-iron.",
                "Putting-style grip, ball back, hands forward.",
                "Land it on the green 1/3 of the way; let it roll out.",
                "Hit 8 balls."
            ],
            successCriteria: "6 of 8 inside 6 ft.",
            skillAreas: [.chippingGreenside],
            clubs: [.shortIrons],
            defaultMinutes: 8,
            suitablePhases: [.block, .transfer],
            zone: .shortGame,
            difficulty: 2,
            reps: "8 chips"
        ),

        Drill(
            id: "chip.lievariety",
            name: "Lie Variety",
            summary: "Random lies — tight, fluff, downhill, rough. Adapt every shot.",
            instructions: [
                "Toss 5 balls into different lies around the green.",
                "Play each one to the same hole with whatever club fits.",
                "Score: 2 = up & down, 1 = inside 6 ft, 0 = outside."
            ],
            successCriteria: "Score ≥6 of 10.",
            skillAreas: [.chippingGreenside, .transferRandom],
            clubs: [.wedges, .shortIrons],
            defaultMinutes: 12,
            suitablePhases: [.transfer, .block],
            zone: .shortGame,
            difficulty: 4,
            reps: "5 lies"
        ),

        Drill(
            id: "chip.upanddown",
            name: "Up & Down Test",
            summary: "Pick 10 random spots within 20 yd. Score yourself like on the course.",
            instructions: [
                "Drop one ball, no second chance.",
                "Get it in the hole in 2 shots.",
                "Pick new spot. Repeat 10 times.",
                "Track up & down percentage."
            ],
            successCriteria: "5 of 10 up & downs.",
            skillAreas: [.chippingGreenside, .transferRandom, .mentalPressure],
            clubs: [.wedges, .putter],
            defaultMinutes: 15,
            suitablePhases: [.transfer],
            zone: .shortGame,
            difficulty: 4,
            reps: "10 attempts"
        ),

        Drill(
            id: "chip.oneclub5",
            name: "One Club, Five Shots",
            summary: "Only your sand wedge — vary loft via setup and motion.",
            instructions: [
                "To the same hole, only with your SW, hit:",
                "1. Low bump-and-run.",
                "2. Standard chip.",
                "3. Higher cut chip (face open).",
                "4. Flop with stable lower body.",
                "5. Spinner — sharp acceleration, hands forward."
            ],
            successCriteria: "All 5 finish inside 8 ft.",
            skillAreas: [.chippingGreenside],
            clubs: [.wedges],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .shortGame,
            difficulty: 4,
            reps: "5 shots"
        ),

        Drill(
            id: "chip.pitch.distances",
            name: "Distance Wedges",
            summary: "Partial wedges at 30, 40, 50, 60 yards. Carry control.",
            instructions: [
                "Use one wedge (SW or GW).",
                "Hit 5 balls at 30 yd, then 5 at 40, 5 at 50, 5 at 60.",
                "Adjust by swing length, not effort.",
                "Score: ≤8 yd = 1 pt, ≤4 yd = 2 pts."
            ],
            successCriteria: "Score ≥24 of 40.",
            skillAreas: [.chippingPitch, .wedgePartial],
            clubs: [.wedges],
            defaultMinutes: 15,
            suitablePhases: [.block],
            zone: .shortGameOrRange,
            difficulty: 3,
            reps: "20 balls"
        ),

        Drill(
            id: "chip.spincontrol",
            name: "Spin Control",
            summary: "Pair high-spin and low-spin chips to the same target.",
            instructions: [
                "Pick a hole 12 yd away on a green that allows running.",
                "Hit 5 high-spin chips: clean lie, sharp descent, hands forward.",
                "Hit 5 low-spin chips: ball back, less wrist, sweep.",
                "Compare landing patterns."
            ],
            successCriteria: "Clear difference in roll-out groups.",
            skillAreas: [.chippingGreenside],
            clubs: [.wedges],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .shortGame,
            difficulty: 4,
            reps: "10 chips"
        ),

        // ───────────────────────────────────────────────
        // MARK: Iron play
        // ───────────────────────────────────────────────
        Drill(
            id: "iron.9window",
            name: "9-Window with 7i",
            summary: "Nine trajectories: high/mid/low × left/center/right.",
            instructions: [
                "Pick a target ~150 yd away.",
                "Hit 9 balls, one for each cell of the 3×3 grid:",
                "high-left, high-center, high-right, mid-left, … low-right.",
                "Plan the ball flight before each swing."
            ],
            successCriteria: "Recognizable difference between cells; 5+ that match intent.",
            skillAreas: [.ironMid],
            clubs: [.midIrons],
            defaultMinutes: 14,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "9 shots"
        ),

        Drill(
            id: "iron.numbergame",
            name: "Number Game",
            summary: "Call the carry distance before each shot, then hit it.",
            instructions: [
                "Pick a club and a target line.",
                "Before each swing, call out a carry number aloud.",
                "Hit. Compare to actual (use a launch monitor or estimate from flags).",
                "5 shots per club, rotating PW → 6-iron."
            ],
            successCriteria: "Average miss < 6 yards of the called number.",
            skillAreas: [.ironShort, .ironMid, .ironLong],
            clubs: [.shortIrons, .midIrons, .longIrons],
            defaultMinutes: 15,
            suitablePhases: [.block, .transfer],
            zone: .range,
            difficulty: 3,
            reps: "20 shots"
        ),

        Drill(
            id: "iron.alignment.path",
            name: "Alignment Stick Path",
            summary: "Two sticks frame your swing path — fix in/out tendencies.",
            instructions: [
                "Lay one stick on the ground along your target line, just inside the ball.",
                "Lay a second 2 ft outside the ball, parallel, forming a corridor.",
                "Hit 10 balls keeping the club through the corridor.",
                "If your miss is a slice/pull — narrow the corridor."
            ],
            successCriteria: "Consistent shape; no contact with either stick.",
            skillAreas: [.ironMid, .ironShort],
            clubs: [.midIrons, .shortIrons],
            defaultMinutes: 10,
            suitablePhases: [.warmup, .block],
            zone: .range,
            difficulty: 2,
            reps: "10 shots"
        ),

        Drill(
            id: "iron.half.pw",
            name: "Half-Swing PW",
            summary: "PW at 50% — controls tempo and contact.",
            instructions: [
                "Use a PW. Take a half backswing (left arm to parallel-ish).",
                "Hit 12 balls focused on smooth tempo, low finish.",
                "Carry should sit around 60 yd, very repeatable."
            ],
            successCriteria: "10+ of 12 strike center-face within 6 yd of target.",
            skillAreas: [.wedgePartial, .ironShort],
            clubs: [.wedges, .shortIrons],
            defaultMinutes: 10,
            suitablePhases: [.warmup, .block],
            zone: .range,
            difficulty: 2,
            reps: "12 shots"
        ),

        Drill(
            id: "iron.random.club",
            name: "Random Club Carousel",
            summary: "Mix clubs and targets every shot — like the course.",
            instructions: [
                "Write down 6 clubs on a list (e.g. 7i, SW, 9i, hybrid, PW, 5i).",
                "Pick a different target for each.",
                "Full routine on every ball: read, commit, swing.",
                "12 shots. Switch club every shot."
            ],
            successCriteria: "Hit your target line on 9 of 12.",
            skillAreas: [.transferRandom, .ironMid, .ironShort, .ironLong],
            clubs: [.shortIrons, .midIrons, .longIrons, .wedges],
            defaultMinutes: 14,
            suitablePhases: [.transfer],
            zone: .range,
            difficulty: 4,
            reps: "12 shots"
        ),

        Drill(
            id: "iron.stinger",
            name: "Stinger Drill",
            summary: "Low 5-iron — ball back, hands forward, knock-down finish.",
            instructions: [
                "Tee a ball low or hit off turf.",
                "Use a 5-iron. Ball 1 inch back of center, hands ahead.",
                "Three-quarter swing, finish low and abbreviated.",
                "Hit 8 balls focused on flighting it down."
            ],
            successCriteria: "Most balls peak under tree-height; consistent shape.",
            skillAreas: [.ironLong],
            clubs: [.longIrons],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "8 shots"
        ),

        Drill(
            id: "iron.fairway.alley",
            name: "Fairway Alley",
            summary: "Mid-iron tee shots into a 20-yd wide alley.",
            instructions: [
                "Pick two range markers ~20 yd apart.",
                "Tee up. Use a mid iron (6, 7, 8).",
                "Hit 10 tee shots — each one must land in the alley.",
                "Count hits. Move alley narrower if you're crushing it."
            ],
            successCriteria: "8 of 10 in the alley.",
            skillAreas: [.ironMid, .driverAccuracy],
            clubs: [.midIrons],
            defaultMinutes: 10,
            suitablePhases: [.block, .transfer],
            zone: .range,
            difficulty: 3,
            reps: "10 shots"
        ),

        Drill(
            id: "iron.stripe.6i",
            name: "Stripe Test 6i",
            summary: "Consistent ball-first contact with a 6-iron.",
            instructions: [
                "Spray your face with foot powder or use impact tape if you have it.",
                "Hit 10 balls with a 6-iron focused on a divot AFTER the ball.",
                "Self-rate strike: thin / center / heavy."
            ],
            successCriteria: "7 of 10 center strikes.",
            skillAreas: [.ironMid],
            clubs: [.midIrons],
            defaultMinutes: 10,
            suitablePhases: [.warmup, .block],
            zone: .range,
            difficulty: 3,
            reps: "10 shots"
        ),

        Drill(
            id: "iron.ladder.gap",
            name: "Iron Ladder",
            summary: "Same swing, descending clubs — proves your gapping.",
            instructions: [
                "Hit 3 shots with each: PW, 9, 8, 7, 6.",
                "Same tempo each time. Note carry distances.",
                "Look for ~10 yd gaps between clubs."
            ],
            successCriteria: "Clean ordering of distances, gaps within 4 yd of expectation.",
            skillAreas: [.ironShort, .ironMid],
            clubs: [.shortIrons, .midIrons],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 2,
            reps: "15 shots"
        ),

        Drill(
            id: "iron.pressure.closeout",
            name: "Pressure Closeout",
            summary: "Three in a row inside 10 yards of the pin — or restart.",
            instructions: [
                "Pick a club and a flag.",
                "You must land 3 consecutive shots within 10 yd of the flag.",
                "Any miss resets the streak to 0.",
                "Limit: 15 balls total."
            ],
            successCriteria: "Chain of 3 within the ball budget.",
            skillAreas: [.mentalPressure, .ironMid, .ironShort],
            clubs: [.shortIrons, .midIrons],
            defaultMinutes: 10,
            suitablePhases: [.transfer],
            zone: .range,
            difficulty: 4,
            reps: "Up to 15 shots"
        ),

        // ───────────────────────────────────────────────
        // MARK: Hybrids / Fairway Woods
        // ───────────────────────────────────────────────
        Drill(
            id: "wood.sweep",
            name: "Fairway Wood Sweep",
            summary: "3-wood off turf — sweep the grass, no divot.",
            instructions: [
                "Place a tee 6 inches behind the ball, lying flat.",
                "Hit a 3-wood; sweep without disturbing the tee.",
                "8 balls."
            ],
            successCriteria: "6 of 8 clean strikes that don't touch the back tee.",
            skillAreas: [.woodsHybrid],
            clubs: [.fairwayWoods],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "8 shots"
        ),

        Drill(
            id: "wood.hybrid.trouble",
            name: "Hybrid From Trouble",
            summary: "Hybrid with a tricky lie — tee low or scruffy mat.",
            instructions: [
                "Set up a degraded lie: tee on the ground, or rough mat.",
                "Use your hybrid. Make a steeper-than-fairway-wood swing.",
                "Hit 8 balls, focus on getting it airborne with shape."
            ],
            successCriteria: "Most balls launch and travel intended shape.",
            skillAreas: [.woodsHybrid],
            clubs: [.hybrids],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "8 shots"
        ),

        Drill(
            id: "wood.tee.deck",
            name: "Tee vs Deck",
            summary: "Same fairway wood — alternate teed up and off the deck.",
            instructions: [
                "Hit 4 with your 3-wood teed low.",
                "Hit 4 with your 3-wood off the mat/turf.",
                "Compare contact and start direction."
            ],
            successCriteria: "Both groups hold a tight start window.",
            skillAreas: [.woodsHybrid, .driverAccuracy],
            clubs: [.fairwayWoods],
            defaultMinutes: 10,
            suitablePhases: [.block, .transfer],
            zone: .range,
            difficulty: 3,
            reps: "8 shots"
        ),

        Drill(
            id: "wood.club.decision",
            name: "Club Decision Hole",
            summary: "Imagine a par 4. Pick a club off the tee. Justify it.",
            instructions: [
                "Visualize a 380-yard par 4 with bunkers at 250.",
                "Pick what you'd hit off the tee (driver / 3w / hybrid / iron).",
                "Hit 3 shots with that club to your intended target.",
                "Then play your 'second shot' from a guessed distance."
            ],
            successCriteria: "Plan matches outcome on at least 2 of 3.",
            skillAreas: [.woodsHybrid, .transferRandom],
            clubs: [.hybrids, .fairwayWoods, .midIrons, .driver],
            defaultMinutes: 12,
            suitablePhases: [.transfer],
            zone: .range,
            difficulty: 3,
            reps: "6 shots"
        ),

        // ───────────────────────────────────────────────
        // MARK: Driver
        // ───────────────────────────────────────────────
        Drill(
            id: "drv.tee.height",
            name: "Tee Height Variety",
            summary: "Three tee heights — see how launch changes.",
            instructions: [
                "Hit 3 shots tee low (half-ball above crown).",
                "Hit 3 shots standard (half-ball above crown).",
                "Hit 3 shots high (ball fully above crown).",
                "Note carry & spin behavior for each."
            ],
            successCriteria: "Identify which height gives best mix of carry and roll.",
            skillAreas: [.driverDistance],
            clubs: [.driver],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 3,
            reps: "9 shots"
        ),

        Drill(
            id: "drv.fadedraw",
            name: "Fade-Draw Alternate",
            summary: "Force shape control off the tee.",
            instructions: [
                "Pick a target line.",
                "Hit shot #1: intentional fade — open face, slightly out-to-in.",
                "Hit shot #2: intentional draw — closed face, in-to-out.",
                "Repeat for 10 total."
            ],
            successCriteria: "Each pair shows a clear shape difference.",
            skillAreas: [.driverAccuracy],
            clubs: [.driver],
            defaultMinutes: 12,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "10 shots"
        ),

        Drill(
            id: "drv.fairway.finder",
            name: "Fairway Finder",
            summary: "Pick a 30-yd alley and pound the driver into it.",
            instructions: [
                "Pick two markers ~30 yd apart at your typical driver carry.",
                "Hit 10 drivers — each must land in the alley.",
                "If your miss is consistently one side, narrow that side."
            ],
            successCriteria: "7 of 10 in the alley.",
            skillAreas: [.driverAccuracy],
            clubs: [.driver],
            defaultMinutes: 12,
            suitablePhases: [.block, .transfer],
            zone: .range,
            difficulty: 3,
            reps: "10 shots"
        ),

        Drill(
            id: "drv.speed.triple",
            name: "Speed Triple",
            summary: "3 max-effort driver swings with rest between sets.",
            instructions: [
                "Warm up properly first.",
                "Hit 3 driver swings at 100% — speed first, shape second.",
                "Rest 60 seconds. Repeat 3 sets (9 total).",
                "Track ball speed if available."
            ],
            successCriteria: "Top-end speeds 2+ mph above your average.",
            skillAreas: [.driverDistance],
            clubs: [.driver],
            defaultMinutes: 10,
            suitablePhases: [.block],
            zone: .range,
            difficulty: 4,
            reps: "9 shots"
        ),

        Drill(
            id: "drv.routine.lock",
            name: "Routine Lock — Driver",
            summary: "Full pre-shot routine on every ball. No exceptions.",
            instructions: [
                "Hit 10 drivers, but EVERY ball gets:",
                "1. Stand behind, pick a target.",
                "2. Visualize ball flight.",
                "3. Step in, align, one practice trigger.",
                "4. Commit and swing within 8 seconds of setup."
            ],
            successCriteria: "Same routine every time, regardless of result.",
            skillAreas: [.driverAccuracy, .mentalPressure],
            clubs: [.driver],
            defaultMinutes: 12,
            suitablePhases: [.transfer],
            zone: .range,
            difficulty: 3,
            reps: "10 shots"
        ),

        // ───────────────────────────────────────────────
        // MARK: Mental / Transfer
        // ───────────────────────────────────────────────
        Drill(
            id: "mix.worstball",
            name: "Worst Ball",
            summary: "Hit two shots, play the worst — replicates back-9 pressure.",
            instructions: [
                "Pick a target.",
                "Hit two balls in a row to that target.",
                "'Play' the worse of the two — that's your next position.",
                "Repeat for 10 shots total."
            ],
            successCriteria: "Stay within a 25-yd window 5+ times in a row.",
            skillAreas: [.mentalPressure, .transferRandom],
            clubs: [.midIrons, .shortIrons, .wedges],
            defaultMinutes: 12,
            suitablePhases: [.transfer],
            zone: .range,
            difficulty: 4,
            reps: "10 shots"
        ),

        Drill(
            id: "mix.simulated.hole",
            name: "Simulated Hole",
            summary: "Driver → iron → wedge → putter. One ball, one swing each.",
            instructions: [
                "Imagine a par-4 you know well.",
                "Tee shot: driver. Approach: hit the iron you'd actually hit.",
                "Pretend wedge approach: hit it.",
                "Then go practice the putt you'd have, 10 yd putt to a flag.",
                "Played to a score? Note it."
            ],
            successCriteria: "Score the hole at or under par.",
            skillAreas: [.transferRandom, .mentalPressure],
            clubs: [.driver, .midIrons, .wedges, .putter],
            defaultMinutes: 14,
            suitablePhases: [.transfer],
            zone: .any,
            difficulty: 4,
            reps: "1-2 holes"
        ),

        Drill(
            id: "mix.the.test",
            name: "The Test (Closing 3)",
            summary: "Three final shots that count — putt, chip, mid iron.",
            instructions: [
                "End your session with these three shots, scored:",
                "1. 6 ft putt — make or fail.",
                "2. Chip from 12 yd — inside 6 ft or fail.",
                "3. 150 yd iron — within 20 yd of pin or fail.",
                "If any fail, log it. The drill is the result."
            ],
            successCriteria: "Pass all 3.",
            skillAreas: [.mentalPressure, .transferRandom],
            clubs: [.putter, .wedges, .midIrons],
            defaultMinutes: 8,
            suitablePhases: [.cooldown, .transfer],
            zone: .any,
            difficulty: 4,
            reps: "3 shots"
        ),

        // ───────────────────────────────────────────────
        // MARK: Cool-down / feel
        // ───────────────────────────────────────────────
        Drill(
            id: "cool.feel.wedge",
            name: "Wedge Feel Putts",
            summary: "Soft wedges to a 30-yd target. End on a quiet, clean strike.",
            instructions: [
                "Pick a 30-40 yd target.",
                "Hit 8 soft, easy SW shots.",
                "No effort grading — just feel and rhythm. Walk away after."
            ],
            successCriteria: "Last 4 in a row feel clean.",
            skillAreas: [.wedgePartial],
            clubs: [.wedges],
            defaultMinutes: 5,
            suitablePhases: [.cooldown, .warmup],
            zone: .shortGameOrRange,
            difficulty: 1,
            reps: "8 shots"
        ),

        Drill(
            id: "cool.feel.putt",
            name: "Lag Feel Cool-Down",
            summary: "10 long putts to nothing in particular — just feel.",
            instructions: [
                "Roll 10 putts of varied length on a flat stretch.",
                "Watch each one finish. No scoring.",
                "Notice what the good ones feel like."
            ],
            successCriteria: "Walk away feeling smooth.",
            skillAreas: [.puttingLag],
            clubs: [.putter],
            defaultMinutes: 5,
            suitablePhases: [.cooldown, .warmup],
            zone: .putting,
            difficulty: 1,
            reps: "10 putts"
        ),
    ]
}
