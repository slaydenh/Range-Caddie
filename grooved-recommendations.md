<div class="cover">

<div class="cover-eyebrow">From Range Caddy → Grooved</div>

<h1 class="cover-title">Lessons from the<br><em>experiment</em></h1>

<div class="cover-sub">Ten ideas worth bringing back to the main app.<br>Plain English. Ranked by impact.</div>

<div class="cover-meta">Internal · May 2026</div>

</div>

# The big picture

We built Range Caddy as a clean-room experiment: same problem as Grooved — turn time, location, and clubs into a real practice session — but no constraints, no brand, no backlog, no users to protect. The point was to find out what happens when you remove every assumption and start over.

Some things came out exactly the same. Three time options. Warm-up, then focus, then a closer. Drills filtered by where you are. That overlap tells us those choices were right.

Other things came out very different. Those differences are the interesting part — they're the ideas that surfaced *because* we let ourselves rebuild from scratch. They're what's worth porting back into Grooved.

This document is that list. Ten ideas, ranked by how much they'll improve Grooved per unit of work to ship them. Each one is described in plain English so we can decide whether it's worth doing before anyone writes a line of code.

<div class="callout" markdown="1">

**A note on framing.** Grooved is the main app we're building. Range Caddy was a sketch — a way to think out loud in working code. Nothing here says "we should rewrite Grooved to be Range Caddy." It's "while we were over there, we noticed these things."

</div>

<div class="page-break"></div>

# Side by side, in plain English

Where the two apps actually differ today.

<div class="comparison" markdown="1">

| | Range Caddy | Grooved |
|---|---|---|
| **Setup taps before your first drill** | Three. Time, where you are, what clubs you brought. | Around ten on a brand-new install. About five thereafter. |
| **Rating a drill** | Three buttons: Struggled, Solid, Dialed. | Two buttons: Nailed It, Not Yet. |
| **How the app learns** | Tracks both a current estimate AND how confident the app is in it. Forgets gradually over about a month. | Tracks "weakness scores" as net tallies. Forgets by session count, not days. |
| **What a new user gets** | The app deliberately surfaces areas it doesn't yet know about, to learn fast. | The same generic session as everyone else, until they tell it their weakness. |
| **Drill library** | 40 hand-tuned drills, fine-grained skill tagging. | About 200 drills, rich written coaching content per drill. |
| **Onboarding** | None. | Five screens before first use. |
| **Pre-round mode** | Doesn't exist. | A whole dedicated flow — bag walk, first-shot rep, short-game tune-up. |
| **Drill swap mid-session** | Removed deliberately. | Front and center. |
| **Brand voice** | Bare minimum. | Genuinely strong: Fraunces, Parchment, gold, voiced cues per drill. |

</div>

The pattern: Range Caddy is **simpler** and **learns better**. Grooved is **richer** in content and brand. Bringing the simpler-and-smarter parts into Grooved is the goal.

<div class="page-break"></div>

# The ten ideas, ranked

Ordered by impact per unit of effort. The top ones move the needle most for the least work.

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">1</div>
<h2>One score per drill, instead of a tangle of rules</h2>
<div class="effort big">Big lift</div>
</div>

**Where it hurts today.** When Grooved builds a session, it picks drills by running them through a chain of about eight different sorting passes. First sort by recent feedback. Then re-sort by weakness. Then re-sort to avoid drills you saw last time. Then re-sort again for welcome-back. Then re-sort for practice intent. Each pass tries to nudge the order, but each one quietly overrides the last. It's hard to predict what comes out, and harder to debug when something feels off.

**The fix.** Compute one number per drill — *how badly do you need this right now* — and rank by that. Bonuses for intent, penalties for "you saw this last time" all become weighted parts of the same score. One thing to read. One thing to test.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> Sessions feel more consistent and react more predictably to the answers given. The math becomes legible to humans, which means it gets better faster.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">2</div>
<h2>Give Grooved a real memory</h2>
<div class="effort medium">Medium</div>
</div>

**Where it hurts today.** The "weakness profile" Grooved keeps today is a tally of integers. Mark a putt drill "Not Yet" three times and "Nailed It" three times and the score collapses to zero — exactly the same as a brand-new user who has never putted in their life. The app has no way to tell those apart.

**The fix.** Give every skill area a proper learning model that tracks two things: what's the current estimate of how good you are, and how confident is the app in that estimate. Range Caddy already does this and the difference is real. A user who has rated a hundred putts is *known*. One who has rated three is *probably-known*. A new user is *unknown* — and the app can say so, then go find out.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> Grooved actually gets smarter the more you use it, in a way you can feel. The first few sessions explore. After ten or so, weaknesses are dialed in. After a long break, the model gracefully resets.</div>

</div>


<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">3</div>
<h2>Three rating buttons, not two</h2>
<div class="effort small">Small</div>
</div>

**Where it hurts today.** "Nailed It" and "Not Yet" sound great on a button. But they throw away a real signal. Hitting 3 of 10 vs 8 of 10 are both "Not Yet" today. To the app, they're identical. They shouldn't be.

**The fix.** Three buttons: **Struggled — Solid — Dialed.** Range Caddy landed on these specifically because three is the sweet spot. A golfer can still tap one-handed at the range, but the app now hears the difference between a barely-passed drill and a crushed one.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> More accurate next sessions, because the app actually heard what they said.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">4</div>
<h2>Drop the session-overall rating</h2>
<div class="effort small">Small</div>
</div>

**Where it hurts today.** Grooved asks two things at session end: an overall "how'd that go" plus a per-drill answer. The overall one is computed from the per-drill ones, with a weird 60% threshold. It's redundant data with extra rules around it, and the code carries leftover values from an older version of the rating.

**The fix.** Delete it. Trust the per-drill answers. The recap can still say "you nailed 4 of 5" without needing a separate vote.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> One less tap. Cleaner numbers behind the scenes.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">5</div>
<h2>Make onboarding optional</h2>
<div class="effort medium">Medium</div>
</div>

**Where it hurts today.** A brand-new golfer has to answer five questions before they're allowed to do anything: name, handicap, biggest weakness, typical miss, short-game confidence. Five doors between a curious tap and a real session. Worse, those answers are barely used — they bias things by a soft factor and are quietly ignored when they don't match the session.

**The fix.** Let them straight in. Range Caddy gets to its first drill in three taps from a cold install. Grooved can do the same. Move the onboarding screens into Settings, and offer them as an optional "set yourself up" card on the home view after the first session. Keep the brand moment that's most loved — the gold "where do you lose the most shots" screen. Just don't gate the first session on it.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> First session is real, fast, and already pretty good — because the learning model does the work the questionnaire used to do.</div>

</div>


<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">6</div>
<h2>Forget by days, not by sessions</h2>
<div class="effort small">Small</div>
</div>

**Where it hurts today.** Grooved's memory of what you struggled with fades based on how many sessions you've done since, not how many days have passed. A golfer who plays five times a week loses their data at the same rate as someone who plays once a month. That's backwards.

**The fix.** Forget by calendar time. A 30-day half-life works well — what you struggled with two months ago is mostly forgotten unless you've reinforced it. Range Caddy uses this and it makes the "coming back after a break" experience feel right.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> The app behaves the way you'd expect after taking a few weeks off — fresh, not stale.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">7</div>
<h2>For new users, explore on purpose</h2>
<div class="effort small">Small</div>
</div>

**Where it hurts today.** A brand-new user has no history. Grooved's whole weakness-tracking system silently does nothing — there's no data to process — so the user gets a generic session and the app has no way to find out what they're actually weak at.

**The fix.** Build "find out" into the learning model. The skills the app knows least about should get bumped up the priority list, on purpose, until there's enough signal. After three sessions the app has a real read on the golfer. Pairs naturally with idea #2.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> The first few sessions feel like the app is figuring them out, instead of guessing.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">8</div>
<h2>Handicap is a hint, not a wall</h2>
<div class="effort medium">Medium</div>
</div>

**Where it hurts today.** Right now Grooved hard-filters the drill library by the handicap a golfer reported. A 100+ player literally cannot see "advanced" drills, even ones they could happily try. A scratch player can't see beginner drills, even when learning a new technique. The wall is too sharp.

**The fix.** Use the handicap as a starting point for the learning model — a hint about where to begin, not a filter on the library. A 100+ golfer's putting starts at "probably-not-great" and the model updates from there. Advanced drills get a soft penalty so they don't show up first, but they aren't impossible to reach.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> More variety. Better fit over time. No invisible walled gardens.</div>

</div>


<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">9</div>
<h2>Tuck the swap button away</h2>
<div class="effort small">Small</div>
</div>

**Where it hurts today.** The drill-swap button on the generated session is right there in the open. It feels nice — agency, control. But the drills the app picks because they're *hard* are exactly the drills golfers will swap away. The escape hatch undermines the work. The data the swap action generates is collected and then never used.

**The fix.** Move swap to a long-press or "..." menu. Not gone — just out of the way. If we don't see anyone digging for it after a few weeks, we have data to remove it entirely.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> You actually do the drill the model thought you needed. The smart-pick gets to do its job.</div>

</div>

<div class="rec" markdown="1">
<div class="rec-head" markdown="1">
<div class="rec-num">10</div>
<h2>A real skill dashboard — once there's data to show</h2>
<div class="effort medium">Medium</div>
</div>

**Where it hurts today.** A skill dashboard would be a lovely feature, but Range Caddy tried it and removed it. New users saw every bar sitting at 50%. It looked like fake data.

**The fix.** Build it, but only show a bar once a golfer has rated drills in that skill area three or more times. Below that threshold, the row says "not enough data yet — keep practicing." When the dashboard does appear, it means something real. Natural fit for a premium tier.

<div class="golfer-line" markdown="1"><span>What changes for the golfer</span> A moment of genuine "the app sees me" — only when it's earned.</div>

</div>

# The brain of the app, in plain language

Ideas #2, #6, and #7 all rely on the same machinery: a small learning model behind the scenes that watches a golfer's ratings and figures out what to surface next. Range Caddy uses a classic statistical trick. Worth explaining what it actually does — without math.

<div class="brain" markdown="1">

**Imagine each skill area as a dial** between 0 (struggling) and 1 (dialed). The app doesn't *know* where the dial is — it has to guess from your ratings.

**Every drill you rate moves the dial.** "Dialed" nudges it up. "Struggled" nudges it down. "Solid" barely moves it.

**The app also tracks how sure it is.** After three ratings, rough guess. After twenty, confident. After zero, "no idea." That confidence is a real number it can use.

**Picking what to show you combines two things.** How far down the dial is (you're weak there), AND how unsure the app is. A weak skill gets practiced. An *unknown* skill also gets practiced, on purpose, so the app can find out.

**Old ratings fade.** Half of what you rated a month ago still counts. After two months, most of it has faded unless you've kept reinforcing it. A golfer back from a long break sees the app sensibly reset.

</div>

That's the whole thing. Grooved already has the inputs — per-drill ratings, skill tags on every drill, dates. It just needs to collect them into dials, not the tally pile it keeps today.

# Wild ideas worth exploring

Things neither app does yet that the comparison surfaced. Opinionated, brainstorm-level, less polished.

<div class="ideas" markdown="1">

<div class="idea" markdown="1">

### Bucket size as the budget

Both apps plan sessions by minutes. But every real range bucket is sized by ball count. Let golfers say "I have a medium bucket — about 80 balls" and have the session plan to use exactly that. The session ends when the balls do.

</div>

<div class="idea" markdown="1">

### Drill graduation

When a golfer has nailed a drill three sessions in a row, the app should mark it "graduated" and stop scheduling it for 30 days. Surfaces fresh material automatically.

</div>

<div class="idea" markdown="1">

### Difficulty ramp inside a block

When a session focuses on irons, the first iron drill should be the easy one and the last should be the hard one. Mirrors how a coach would run a session: groove, then push.

</div>

<div class="idea" markdown="1">

### A weekly plan, not just session plans

"I'll practice three times this week" → the app distributes focus across those three sessions. Session 1: your worst area. Session 2: a different area. Session 3: pre-round tune-up.

</div>

<div class="idea" markdown="1">

### Confidence-targeted finisher

If the session has mostly been "Struggled," end on something confidence-building. If it's been mostly "Dialed," end on a pressure closer. The metadata exists; nothing reads it dynamically yet.

</div>

<div class="idea" markdown="1">

### Hands-free rating at the range

"Hey Siri, that was solid." An Apple Watch companion with a quick three-button rating. Both apps require pulling the phone out between drills. Removing that friction is a real unlock — at the range, your hands are busy.

</div>

</div>

<div class="page-break"></div>

# What NOT to take from Range Caddy

A few choices that made sense in the experiment but would be wrong for Grooved.

<div class="anti-items" markdown="1">

<div class="anti-item" markdown="1">

**Don't go granular with skill areas.** Range Caddy tracks 15 different sub-skills — short putting, mid putting, lag putting, breaking putts, and so on. That was tractable for a 40-drill library tagged from scratch. Grooved's 200 drills are tagged across broader categories. Re-tagging them all isn't worth it. Use Grooved's existing six focus areas as the dials.

</div>

<div class="anti-item" markdown="1">

**Don't drop onboarding entirely.** Range Caddy has no onboarding because it has no brand. Grooved's onboarding includes the gold "where do you lose the most shots" moment — that *is* the brand. Make onboarding optional. Don't delete it.

</div>

<div class="anti-item" markdown="1">

**Don't strip drill content.** Range Caddy's drill instructions are workmanlike: "Hit 10 putts from 6 ft." Grooved's drills have a swing thought, a key thought, a "why it helps," and a hint. That voice is half of what makes Grooved feel like Grooved.

</div>

<div class="anti-item" markdown="1">

**Don't bundle facilities into composite buckets.** Range Caddy collapsed facility choice into four mutually-exclusive options (Full, Range, Short, Putt). Grooved lets a golfer pick any combination — range plus putting, no chipping green at this place. That's a real configuration and Grooved's model is more correct.

</div>

<div class="anti-item" markdown="1">

**Don't drop the per-drill timer.** Range Caddy doesn't track how long a golfer actually spent on each drill. Grooved does. That data feeds future "you spend longer on chipping than you think" insights and lets us tune drill duration defaults. Keep it.

</div>

</div>

<div class="page-break"></div>

# If we ship only three

The biggest wins for the next quarter, in order.

<div class="priorities" markdown="1">

<div class="priority" markdown="1">
<div class="priority-num">1</div>
<div class="priority-body" markdown="1">

**The real memory** (idea #2). This is the unlock that makes every other smart-pick improvement possible.

</div>
</div>

<div class="priority" markdown="1">
<div class="priority-num">2</div>
<div class="priority-body" markdown="1">

**Three rating buttons** (idea #3). Small change. It's the input the new memory needs to work properly.

</div>
</div>

<div class="priority" markdown="1">
<div class="priority-num">3</div>
<div class="priority-body" markdown="1">

**Optional onboarding** (idea #5). The first-session experience is currently the worst part of the funnel.

</div>
</div>

</div>

Everything else can follow. The single-score selection (idea #1) is the most ambitious but it pays for itself by making the rest legible and testable. The wild ideas wait until the core gets solid.

<div class="end-mark">— end —</div>
