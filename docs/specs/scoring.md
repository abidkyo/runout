# Scoring — MatchNotifier

Owns: transitions, rotation scoring, straight-pool rules, fouls, undo/redo,
one-shot flags. File: `lib/features/match/match_notifier.dart`.

## API

- `match` — current immutable `Match`; `currentBreakerIndex` shortcut.
- `canUndo` / `canRedo` — stack non-empty.
- `selectBreaker(i)` — `created` only. Starts the match, sets `startedAt` and
  the breaker. Straight pool counts the breaker's first inning. Asserts and
  early-returns for wrong status or index.
- `incrementScore(i, {points = 1, remaining, keepsTurn = false,
  foul = Foul.none})` — main transition. One call = one visit in straight
  pool.
- `endVisit()` — straight pool; `incrementScore(breaker, points: 0)`.
- `scoreRemaining(n, {keepsTurn, foul})` — straight pool; requires
  `2 <= n <= remaining`; points = `remaining - n`.
- `newRack(n)` — straight pool; `n` is 0 or 1; points = `remaining - n`;
  resets `remaining` to 15; always keeps the turn.
- `undo()` / `redo()` — snapshots; any new action clears redo.

Straight-pool helpers take no `sideIndex`: the breaker always scores, so they
read `currentBreakerIndex ?? 0`. The `?? 0` is safe because `incrementScore`
rejects non-playing matches.

Flags `notifyExtension`, `notifyThreeFouls`, `askToContinue` are public bools,
reset near the top of a valid `incrementScore`; the UI reads and resets them.

## Rotation games (8/9/10-ball)

- `incrementScore(i)` adds `points` to side `i`.
- `scores[i] >= raceTo` finishes the match; the scorer wins.
- Next breaker: `winnerBreak` keeps the scorer; `alternateBreak` advances
  `(current + 1) % sides.length`.
- Straight-pool fields stay untouched.

## Straight pool

### Visits and runs

- One `incrementScore` call = one visit; `points` is the visit total and `0`
  is valid (no score, turn passes).
- Innings are counted **before** a visit: `selectBreaker` counts the opening
  break; each turn-ending score increments the **next** breaker's innings.
  `innings[i]` can be one ahead of completed visits; the UI clamps to
  `effectiveInningsLimit`.
- `currentRun` adds `points` per call (fouls are not subtracted).
  `highRuns[i]` is raised live on every call. The run resets only when the
  turn ends, after the max is taken. One `int` is enough: only the active side
  can have a non-zero run.
- Average is derived (`score / innings`), never stored.

### Win conditions

Score win takes priority over the innings limit.

1. If `scores[i] >= raceTo`: a normal turn end finishes with `winnerIndex =
   i`; a kept turn sets `askToContinue` instead.
2. Otherwise, on a turn-ending visit: increment `innings[nextBreaker]`. If
   any innings value exceeds `effectiveInningsLimit`, the highest score wins.
   A unique leader wins; a tie extends the limit by 5 and sets
   `notifyExtension`.

Tie detection uses `reduce(max)` plus a winners list, so it works for any
side count.

### Table state

- `scoreRemaining` handles a normal visit end (`n >= 2`); `newRack` handles a
  cleared rack (`n` 0 or 1). Both derive points from the remaining-count
  difference; the split is asserted.
- `newRack` keeps the turn and may reach the target; on a kept turn the
  target prompts instead of finishing (`match-ui.md`).

### Fouls

Folded into `incrementScore` because a foul always ends a visit or forces a
re-break; splitting would duplicate win/innings logic.

- Score update: `+= points - foul.value`.
- `standard` increments `foulCounters`; at 3 it resets to 0, applies the
  15-point penalty on top of the foul value, and forces the turn.
- `none` and `breakFoul` reset the counter. Only `standard` counts toward the
  three-foul penalty.
- `effectiveKeepsTurn = keepsTurn || isThirdFoul`; callers cannot opt out.
- A third foul also re-racks to 15, sets `isOpeningBreak`, and sets
  `notifyThreeFouls`.
- `breakFoul` gets `keepsTurn` from the dialog (Re-break/Continue). No points
  can be scored: the UI disables the balls, and the notifier asserts and
  returns if `points != 0`.
- `isOpeningBreak` starts true and clears after any scoring call except a
  `breakFoul` that keeps the turn. It gates the break-foul option.

### Guards and shape

- Not `playing` → silent return. Out-of-range index, negative points, scorer
  ≠ breaker, wrong game type, or bad `remaining` → assert + return. Tests
  verify the asserts; release builds take the early return.
- `incrementScore` is single-exit: compute results, `_pushHistory()`,
  `copyWith`, then one `notifyListeners()`. `winnerIndex != null` is the
  finished signal; `copyWith` keeps `status`/`endedAt` otherwise.

## Undo/redo and flags

- Snapshot stacks hold whole `Match` values; undo can return to `created`.
- Flags are not snapshotted and `undo()` does not clear them; the next
  `incrementScore` resets all three. UI helpers reset them after use.
- `notifyExtension` and `notifyThreeFouls` are mutually exclusive: a third
  foul forces `keepsTurn`, skipping the innings branch.
