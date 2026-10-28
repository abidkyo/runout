# Product — scope, status, roadmap

Owns: what the app is, current status, next work, open questions.

## Apps

Runout is a billiard scoring app.

- **Client** (the only app being built) — players/referees score matches.
  All Flutter targets: Android, iOS, web, Linux, macOS, Windows.
- **Manager** — organizes matches/tournaments, views results. Deferred.

Flow: `HomePage` (mode grid) → `MatchSetupPage` (players + rules) →
`MatchPage`. Restart returns to setup; exit returns home.

## Modes

| Mode | Sides | Players/side | Notes |
| --- | --- | --- | --- |
| Singles | 2 | 1 | |
| Doubles | 2 | 2 | Shared score |
| Three-player | 3 | 1 | |
| Tournament | 0 | 0 | No flow; home card is a no-op |

`MatchMode` exposes `displayName`, `sideCount`, and `playersPerSide`. Home
icons are mapped in `features/home/`, keeping `domain/` Flutter-free.

## Game types

- **8/9/10-ball** — one point per rack, `raceTo` target. No fouls, innings,
  or table state.
- **Straight pool / 14.1** — one point per ball, `raceTo` target plus an
  innings limit and fouls. See `scoring.md`.

`GameType.displayName` is the title label; `shortName` is used in tight
layouts and differs only for straight pool (`'Straight Pool'` / `'14.1'`).

## Status

Done: client flow, setup, rotation and straight-pool scoring, undo/redo,
timer, responsive layouts, unit and widget tests.

## Next

1. Persistence (local DB).
2. Match history.
3. Manager app, then sync protocol (WebSocket likely).
4. Tournament waiting page and flow.

## Open questions

- Deliberate/serious fouls in straight pool (15-point penalty, referee
  discretion).
- Persistence choice (Drift, Isar, or similar).
- Tournament naming/scope; `MatchMode.tournament` may change.
- Text-scale-aware sizing; padding is currently fixed at the 1.5× scale.
- No per-platform smoke test yet; widget tests cover compact/wide widths.
