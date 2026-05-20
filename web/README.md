# Range Caddy — Web

Single-file web version of the iOS app. Same engine, same drill library,
runs anywhere with a modern browser.

## How to use

1. Open `index.html` in any modern browser. You can:
   - **Double-click the file** to open via `file://`, OR
   - Run a static server in this folder (`python3 -m http.server 8000`) and visit `http://localhost:8000/`, OR
   - Open it on your phone (AirDrop the file, or host it somewhere).

2. Data is stored in `localStorage` — sessions and the learned skill model
   persist across reloads on the same browser. Clear from the History tab.

3. To preview the smart-pick behavior without grinding through real sessions,
   tap **Seed demo data** on the home or skills tab. It creates 3 plausible
   past sessions (short game weak, driver strong) so the next generation
   visibly tilts toward your "weak" areas.

## What's the same as the iOS app?

- Beta-Binomial posterior per skill area with 30-day time-decay
- Thompson sampling drives drill selection
- Phase-structured plan: warm-up → focus blocks → transfer → cool-down
- 40-drill library, 15 skill areas, 8 facility types, 8 club categories
- Recency penalty so drills don't repeat across consecutive sessions

## What's different?

- Storage is `localStorage` (web) vs SwiftData (iOS)
- Pure DOM rendering, no SwiftUI — visually approximated with iOS-style
  cards, pills, tab bar, dark-mode-aware palette
- No App Store / push notifications / HealthKit
