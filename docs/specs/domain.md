# Domain

## Model decisions

- `MatchSide` exists so doubles share one score and `sides` is not
  `List<List<Player>>`. It has no id; position in `Match.sides` is the
  reference.
- `MatchStatus` lives in `match.dart`; it is not reused elsewhere.
- `copyWith` uses plain `??`: null means "keep current", so it cannot clear a
  nullable field. Transitions rely on the current value already being right.
- Lifecycle invariants are convention-only, not asserted:
  - `created`: timestamps, breaker, winner null.
  - `playing`: `startedAt` and `currentBreakerIndex` set; `endedAt` and
    `winnerIndex` null.
  - `finished`: `endedAt` and `winnerIndex` set.

## Scoring decisions

- One `incrementScore` call is one straight-pool visit. Innings are counted
  **before** the visit, so `innings[i]` can be one ahead of completed visits;
  the UI clamps the display.
- Score win takes priority over the innings limit. On a kept turn, reaching
  the target asks instead of finishing.
- An innings tie extends the limit by 5; a unique high score wins.
- `currentRun` accumulates raw points (fouls are not subtracted), and
  `highRuns` is raised live. Average is derived, never stored.
- Fouls live in `incrementScore` because a foul always ends a visit or forces
  a re-break. A third standard foul forces the turn and re-racks. A break foul
  cannot carry points.
- `isOpeningBreak` gates the break-foul option; it clears after a scoring
  call except a break foul that keeps the turn.
- `incrementScore` is single-exit: compute, push history, one notify.
  `winnerIndex != null` is the finished signal.
- `notifyExtension`, `notifyThreeFouls`, and `askToContinue` are one-shot
  flags reset by the next `incrementScore`. They are not snapshotted, so
  `undo()` does not clear them.
- Extension and three-foul notifications are mutually exclusive: a third
  foul forces `keepsTurn`, skipping the innings branch.
