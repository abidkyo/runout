# Architecture

## Layout

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/
│   ├── settings/
│   └── theme/
├── data/
│   ├── local/
│   └── repositories/
├── domain/
│   ├── enums/
│   └── models/
├── features/
│   ├── history/
│   ├── home/
│   ├── manager_link/
│   ├── match/
│   ├── match_setup/
│   ├── settings/
│   └── tournament/
└── shared/
    └── widgets/
test/
├── unit/
└── widget/
```

## Layers

- `features/` → `domain/`, `data/`, `shared/`, `core/`.
- `data/` → `domain/`, `core/`. Never `features/`.
- `domain/` → no app imports, no Flutter. Pure Dart.
- `shared/` → `core/`, `domain/`. Never `features/`.
- No import linter; enforce by review.

## Feature folders

- Public widgets live in `features/<feature>/widgets/`; pages and notifiers
  stay at the feature root.
- Pages are thin: create page-level notifiers when needed, route, and delegate
  layout.
- One-off subwidgets stay private in the using file.

## Composition

- `RunoutApp` owns the settings notifier and passes the selected theme, color,
  and text scale to `MaterialApp`. Theme and text scale changes apply
  immediately.
- `main` opens the local `AppDatabase`, loads the settings, player, and match
  repositories, and passes them to `RunoutApp` through `AppProviders`. Startup
  waits at most 10 seconds; a load failure continues with defaults or empty
  repositories and a one-time warning.
- The Home shell uses a compact AppBar and `NavigationBar`; wide layouts use a
  sidebar. Settings is a shell tab.
- `MaterialApp` uses light and dark themes selected by settings and overrides
  system text scaling with the saved scale; no router or named routes.
- `MatchPage` owns match actions; the match header, side cards, controls bar,
  and buttons are presentational. A page-level `MatchPersistence` provider
  mirrors notifier changes into the repository and is disposed with the page.
- Targets all Flutter platforms. No platform-specific branches, conditional
  imports, or `dart:io`.

## State and data

- Provider only, no global state. Feature notifiers are `ChangeNotifier`;
  providers are created at page level.
- Home reads `MatchRepository` directly; `getFinished(limit:)` supplies the
  recent cap. Match deletion is used by Discard and Setup; history deletion is
  still deferred to the future `MatchDetailPage`.
- Use `context.watch` to rebuild, `context.read` for actions,
  `Consumer`/`Selector` for partial rebuilds.
- Undo/redo stores immutable `Match` snapshots in two stacks.
- Drift is the only local database. `players` and `matches` store a versioned
  JSON snapshot (`playerJson`, `matchJson`) plus scalar columns used for ordered
  reads. JSON snapshots are `{"version": 1, "player"|"match": {...}}`.
- `PlayerCodec` and `MatchCodec` own encode/decode. A malformed or unsupported
  row is skipped and logged instead of failing the whole load.
- Player and match writes always go through the repositories. Match writes
  happen after every `MatchNotifier` change through `MatchPersistence`; created
  matches are never stored, and undo back to `created` deletes the row.
  `MatchPersistence` serializes writes, retries three times at 200 ms, and
  reports the final failure once.
- Discard and Setup delete the stored match without waiting for the delete before
  navigating; a failure leaves the row and shows a snackbar. Exiting to Home
  keeps the row.
- Timestamps are stored as UTC; loaded matches use local timestamps so the UI's
  date and elapsed-time logic matches in-session matches.
- Repositories load once at startup and serve synchronous reads from an
  in-memory cache. Screens do not observe repository changes while a route is
  open; data refreshes on reload, tab switch, or revisit.
- Settings are persisted with `shared_preferences`. No network or sync yet.
- Offline-first is the intended direction; the repository layer will hide
  local/remote later. Don't add persistence ad hoc.
- IDs use UUID v7.

## Scope guards

- No `ScoringRule` abstraction yet; extract only when a third rule set appears.
- Timer is UI-only; duration is derived, never stored.
- `shared_preferences` is limited to app settings.
- No migrations beyond schema version 1 yet; the local database is pre-release.
