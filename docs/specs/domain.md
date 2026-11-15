# Domain

## Model decisions

- `MatchSide` owns the per-side stats: `score`, `innings`, `highRun`, and
  `consecutiveFouls`. `Match.sides` is the only per-side state; there are no
  parallel lists.
- `MatchSide` exists so doubles share one score and `sides` is not
  `List<List<Player>>`. It has no id; position in `Match.sides` is the
  reference.
- `Match.currentSideIndex` is the side currently breaking. It is null before
  the starting side is selected. `selectStartingSide` starts the match.
- `Match.ballsRemaining` is the balls-left count for straight pool.
- `Match.effectiveInningsLimit` is non-null; it is zero outside straight pool.
- `MatchConfig.inningsLimit` is non-null. Straight pool requires a positive
  value and alternate break; rotation games require `0`.
- `MatchStatus` lives in `match.dart`; it is not reused elsewhere.
- Models are Freezed classic classes with normal `const` constructors. This
  keeps native `assert(...)` instead of `@Assert`; Freezed generates
  `copyWith`, equality, `hashCode`, and `toString`.
- Freezed `copyWith` clears nullable fields when passed `null`. `endedAt` and
  `winnerIndex` are null until the match finishes, so transitions pass `null`
  for them while playing.
- Lifecycle invariants are convention-only, not asserted:
  - `created`: timestamps, current side, winner null.
  - `playing`: `startedAt` and `currentSideIndex` set; `endedAt` and
    `winnerIndex` null.
  - `finished`: `endedAt` and `winnerIndex` set.

## Scoring decisions

- `scoreRack` is the 8/9/10-ball entry point: one call awards one rack.
- `scoreVisit` is the straight-pool entry point: one call is one visit.
  Innings are counted **before** the visit, so `innings` can be one ahead of
  completed visits; the UI clamps the display.
- `scoreVisit` and `scoreRemaining` end the visit by default. Pass
  `endsInning: false` to keep the turn. `newRack` keeps the turn.
- `scoreRack` and `scoreVisit` are single-exit: compute, push history, one
  notify. `winnerIndex != null` is the finished signal.
- Score win takes priority over the innings limit. On a kept turn, reaching
  the target asks instead of finishing.
- An innings tie extends the limit by 5; a unique high score wins.
- `currentRun` accumulates raw points (fouls are not subtracted), and
  `highRun` is raised live. Average is derived, never stored.
- Fouls live in `scoreVisit` because a foul always ends a visit or forces a
  re-break. A third standard foul forces the turn and re-racks. A break foul
  cannot carry points.
- `isOpeningBreak` starts true. It gates the break-foul option and clears
  after a scoring call except a break foul that keeps the turn.
- `notifyExtension`, `notifyThreeFouls`, and `askToContinue` are one-shot
  flags reset by the next scoring call. They are not snapshotted, so `undo()`
  does not clear them.
- Extension and three-foul notifications are mutually exclusive: a third
  foul forces the turn, skipping the innings branch.
