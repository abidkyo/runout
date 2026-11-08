# Product

A cross-platform billiard scoring app designed to make tracking match scores simple and intuitive.

## Supported Game Modes
- Singles (1 vs 1)
- Doubles (2 vs 2)
- Three-player matches (1 vs 1 vs 1)

## Supported Games
- 8-ball
- 9-ball
- 10-ball
- Straight Pool

## Platform Strategy
- Built with Flutter.
- Target platforms: Android, iOS, Web, Linux, macOS, and Windows.
- Primary development and testing focus: Web.

Flow: home → setup → match.

## Status

Done: client flow, rotation and straight-pool scoring, undo/redo, timer,
responsive layouts, tests.

Next:

1. Persistence (local DB).
2. Match history.
3. Manager app, then sync (WebSocket likely).
4. Player list.
5. Tournament page.

## Open questions

- Deliberate/serious fouls in straight pool (15-point penalty, referee
  discretion).
- Persistence choice (Drift, Isar, or similar).
- History detail, delete, and export.
- Player profile editing (rename, delete, country/club).
- Language and localization scope.
- No per-platform smoke test; widget tests cover compact/wide widths.
