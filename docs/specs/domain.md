# Domain — models, enums, constants

Owns: pure data and its invariants. Behavior: `scoring.md`; setup state:
`setup.md`.

## Constants

Static-only holders (`Class._()`):

- `MatchLimits` — `minRaceTo 1`, `maxRaceTo 999`, `minInnings 1`,
  `maxInnings 99`. Setup setters clamp against these; add a new pair here
  rather than inline literals.
- `MatchDefaults` — `inningsExtension 5`, `threeFoulsPenalty 15`.
- `LayoutBreakpoints` — `compact 600`, `wide 800`. Compared against
  `LayoutBuilder` constraints, not screen size.

## Enums

One enum per file in `domain/enums/`; values are lowerCamelCase.

**`MatchMode`** — `singles`, `doubles`, `threePlayer`, `tournament`.

- `sideCount`: 2, 2, 3, 0.
- `playersPerSide`: 1, 2, 1, 0.
- `displayName` for UI labels. Home icons are mapped in the home feature.

**`GameType`** — `eightBall`, `nineBall`, `tenBall`, `straightPool`.

- `displayName`: `'8 Ball'`, `'9 Ball'`, `'10 Ball'`, `'Straight Pool'`.
- `shortName`: same except `'14.1'` for straight pool. Two getters so a
  future divergence costs nothing.

**`BreakFormat`** — `winnerBreak`, `alternateBreak`. Decides who breaks the
**next rack**. Straight pool uses `alternateBreak`, enforced in
`MatchConfig`.

**`Foul`** — `none`, `standard`, `breakFoul`. `displayName`:
`'No Foul'`, `'Foul'`, `'Break Foul'`. `value`: 0, 1, 2, subtracted from the
score.

## Models

One model per file in `domain/models/`. All are `@immutable`; no
`==`/`hashCode` overrides and no serialization yet.

**`Player`** — `id` (UUID string), `firstName`, `lastName`,
`countryCode?` (ISO alpha-2), `clubName?`. Getter `fullName`.

**`MatchSide`** — `List<Player> players`, length 1–2, asserted non-empty. No
`id`: position in `Match.sides` is the reference. Exists so doubles share a
score and `sides` is not `List<List<Player>>`.

**`MatchConfig`** — `matchMode`, `gameType`, `raceTo`, `breakFormat`
(required), `inningsLimit?`.

- `raceTo` is the target for every game type.
- `inningsLimit` is required for straight pool and forbidden otherwise.
- `breakFormat` must be `alternateBreak` for straight pool.
- One constructor assert enforces the straight-pool combination.

**`Match`** — immutable match state.

- `MatchStatus { created, playing, finished }` lives in `match.dart` rather
  than its own file.
- `id`, `config`, `sides` (≥2, order = index), plus parallel lists `scores`,
  `innings`, `highRuns`, `foulCounters`. List lengths are asserted to equal
  `sides.length`.
- Straight pool only: `remaining` (15), `currentRun` (0),
  `effectiveInningsLimit` (starts at `config.inningsLimit ?? 0`, grows by 5
  on a tied limit), `isOpeningBreak` (true).
- Lifecycle: `status`, `startedAt?`, `endedAt?`, `currentBreakerIndex?`,
  `winnerIndex?`.
- `innings` = visits per side; `highRuns` = best single visit; `foulCounters`
  = consecutive standard fouls. Rotation games leave all three zero.
- `Match.create(id:, config:, sides:)` allocates the parallel lists, seeds
  `effectiveInningsLimit`, and sets status `created`.
- `copyWith` uses plain `??`: **null means "keep current"**, so it cannot
  clear nullable fields. Transitions rely on this.

Lifecycle invariants are convention-only (not asserted):

- `created`: timestamps, breaker, and winner null.
- `playing`: `startedAt` and `currentBreakerIndex` set; `endedAt` and
  `winnerIndex` null.
- `finished`: `endedAt` and `winnerIndex` set.
