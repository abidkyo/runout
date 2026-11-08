# Product

Client app only: score singles, doubles, and three-player matches
for 8/9/10-ball and straight pool. Targets all Flutter platform. The manager app
(organize matches, view results) is deferred.

Flow: home → setup → match.

## Status

Done: client flow, rotation and straight-pool scoring, undo/redo, timer,
responsive layouts, tests.

Next:

1. Persistence (local DB).
2. Match history.
3. Manager app, then sync (WebSocket likely).

## Open questions

- Deliberate/serious fouls in straight pool (15-point penalty, referee
  discretion).
- Persistence choice (Drift, Isar, or similar).
- No per-platform smoke test; widget tests cover compact/wide widths.
