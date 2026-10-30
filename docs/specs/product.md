# Product

Client app only: score singles, doubles, three-player, and tournament matches
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
4. Tournament waiting page and flow.

## Open questions

- Deliberate/serious fouls in straight pool (15-point penalty, referee
  discretion).
- Persistence choice (Drift, Isar, or similar).
- Tournament naming/scope.
- No per-platform smoke test; widget tests cover compact/wide widths.
