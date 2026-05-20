# Range Caddy

A native iOS app that turns your available time, facility, and clubs into a
structured 30–60 minute practice session — and gets smarter every time you use it.

## What it does

1. You tell it three things: **facility, time, clubs**.
2. It generates a phase-structured session (warm-up → focus blocks → transfer/pressure → cool-down) tailored to your inputs.
3. It walks you through each drill with a timer, instructions, and pass criteria.
4. You rate each drill 1–5 when you're done.
5. A per-skill Bayesian model updates. Next time, weaknesses are surfaced more often, and recent drills are de-emphasized so you don't repeat yourself.

The model is fully local. No accounts, no backend, no network.

## Architecture

```
RangeCaddy/
├── RangeCaddyApp.swift             SwiftUI @main + SwiftData container
├── Models/                         Data models
│   ├── Enums.swift                 ClubCategory, Facility, SkillArea, …
│   ├── Drill.swift                 Static drill definition
│   ├── DrillRecord.swift           @Model: drill instance inside a session
│   ├── Session.swift               @Model: a generated session
│   ├── SkillState.swift            @Model: Beta(α,β) posterior per skill
│   └── UserPreferences.swift       @Model: last-used setup
├── Data/
│   └── DrillLibrary.swift          40-drill curated seed library
├── Engine/
│   ├── BayesianModel.swift         Beta-Binomial updates + Thompson sampling
│   └── SessionGenerator.swift      Phase planner + drill selector
└── Views/                          SwiftUI screens
    ├── ContentView.swift           Tab root
    ├── HomeView.swift              Landing, "New Session", focus insights
    ├── SessionSetupView.swift      Facility / time / club picker
    ├── SessionPlanView.swift       Generated drill list
    ├── DrillRunnerView.swift       Timer + instructions
    ├── DrillRatingView.swift       1–5 rating + notes
    ├── SessionSummaryView.swift    Skill-posterior deltas
    ├── HistoryView.swift           Past sessions
    ├── SkillDashboardView.swift    Per-skill bars w/ uncertainty band
    └── Components/SkillBar.swift
```

### How the learning works

Each `SkillArea` (e.g. `puttingShort`, `ironMid`, `driverAccuracy`) carries a
**Beta(α, β)** posterior over mastery in `[0, 1]`. A drill rating contributes a
fractional success observation:

| Rating       | Treated as |
|--------------|-----------:|
| Excellent    | 0.92       |
| Good         | 0.75       |
| Average      | 0.55       |
| Below        | 0.30       |
| Poor         | 0.10       |

Updates are weighted by:
- the drill's **primary vs secondary** skills (1.0, 0.6, 0.4)
- the drill's **difficulty** (harder drills count slightly more)
- a **time-decay** (half-life 30 days) so old data fades and the model stays responsive

When generating the next session, the planner does **Thompson sampling** —
draws θ from each Beta posterior and treats `1 - θ` as that skill's "need" right
now. That balances *exploitation* (focus on known weaknesses) with *exploration*
(revisit skills we're uncertain about).

The planner then:
1. Filters drills by facility + selected clubs.
2. Scores each candidate against current need, with a recency penalty for
   drills used in the last two sessions.
3. Packs the best drills into a phase budget that fits your selected time
   (warm-up ≈ 15 %, focus blocks ≈ 55 %, transfer ≈ 20 %, cool-down ≈ 10 %).

## Building

Requirements:

- **Xcode 15 or newer**
- **iOS 17 deployment target** (SwiftData + `@Bindable` etc.)
- A Mac. (This repo was scaffolded in a Linux container, so the project file is
  hand-written. It opens cleanly in Xcode 15+, but you'll need Xcode itself to
  compile.)

Steps:

```bash
git clone <this repo>
cd Range-Caddie
open RangeCaddy.xcodeproj
```

Then in Xcode:
1. Select the **RangeCaddy** scheme.
2. Pick a simulator (iPhone 15 works well) or your own device.
3. ⌘R.

### If the project won't open

The pbxproj is hand-rolled. If Xcode complains, the fallback is dead simple —
the source tree is standard:

1. `File → New → Project → iOS → App`.
2. Name: `RangeCaddy`, Interface: SwiftUI, Language: Swift, Storage: SwiftData.
3. Delete the auto-generated `RangeCaddyApp.swift` and `ContentView.swift`.
4. Drag the entire `RangeCaddy/` folder from this repo into the new project
   ("Copy items if needed" off, "Create groups" on).
5. Set the deployment target to iOS 17.
6. Build.

## Roadmap / good next moves

- Stat tracking inside a drill (made/missed counters, not just 1–5).
- HealthKit step/distance integration.
- iCloud sync (`ModelConfiguration(cloudKitDatabase:)`).
- Drill add-your-own UI for custom routines.
- Apple Watch companion for the timer + quick rating.
