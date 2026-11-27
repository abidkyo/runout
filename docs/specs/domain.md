# Domain

## Models

- `MatchSide` owns the per-side score, innings, high run, and consecutive fouls.
  Sides are ordered; position is the identity, so doubles share one score.
- `currentSideIndex` is the side currently breaking. It is null before the
  starting side is chosen.
- `ballsRemaining` is the straight-pool ball count. `effectiveInningsLimit` is
  zero outside straight pool.
- Pausing sets `pausedAt`; completed pauses accumulate in `totalPausedSeconds`.
  Elapsed play time is derived from the start, end, and pause fields, and is
  never stored.
- Pause and resume change only timing and add no undo step. Finishing clears the
  pause.
- `inningsLimit` is non-null. Straight pool requires a positive value and
  alternate break; rotation games use zero.

## Lifecycle

- `created`: no timestamps or winner, and no starting side.
- `playing`: start time and current side set; no end time or winner; paused time
  set while paused.
- `finished`: end time and winner set; paused time null.

Lifecycle rules are conventions, not runtime assertions.

## Scoring

- `scoreRack` is the 8/9/10-ball entry point: one call awards one rack.
- `scoreVisit` is the straight-pool entry point: one call is one visit. Innings
  count before the visit, so the stored count can be one ahead; the UI clamps
  the display.
- Scoring a visit or the remaining balls ends the visit unless the turn is kept;
  a new rack keeps the turn.
- Score win takes priority over the innings limit. On a kept turn, reaching the
  target asks whether to continue.
- An innings tie extends the limit by 5; a unique high score wins.
- `currentRun` accumulates raw points (fouls are not subtracted); `highRun`
  updates live. Average is derived.
- Fouls are part of `scoreVisit` because a foul ends the visit or forces a
  re-break. A third standard foul forces the turn and re-racks. A break foul
  scores no points.
- The opening break starts true, gates the break-foul option, and clears after
  scoring, except a break foul that keeps the turn.
- Extension and three-foul prompts are one-shot and reset on the next scoring
  call; undo does not clear them. A third foul skips the extension branch.
