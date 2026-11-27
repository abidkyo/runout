# Architecture

## Structure

- `core/`: constants, settings, and theme.
- `data/`: local database and repositories.
- `domain/`: enums and models.
- `features/`: one folder per feature. Pages and notifiers live at the feature
  root; public widgets live under `widgets/`.
- `shared/`: reusable widgets.

Dependencies point inward: features may use data, domain, shared, and core; data
and shared never import features; domain is pure Dart.

## App shell

- `main` opens the local database, loads settings, players, and matches, then
  passes repositories to `RunoutApp` through `AppProviders`. A load failure
  continues with default settings, empty repositories, and one warning.
- `RunoutApp` owns settings and applies theme, color, and text scale
  immediately.
- Home uses a bottom navigation bar when compact and a sidebar when wide.
  Settings is a tab.
- No router or named routes.
- All platforms are supported without platform-specific code.

## State and data

- Provider only. Feature notifiers are `ChangeNotifier` at page level;
  `AppProviders` owns app-level repositories and `MatchListNotifier`.
- `MatchListNotifier` is the change signal for Home and Match History.
  Repositories stay data-only.
- Undo/redo stores immutable `Match` snapshots.
- Drift is the only local database. Players and matches are stored as versioned
  JSON snapshots plus columns for ordered reads. Malformed rows are skipped and
  logged.
- All writes go through repositories. `MatchPersistence` saves match changes
  after every notifier update. A match that is still created is not stored;
  undoing back to created deletes the row. Failed saves retry, then report once.
- Repositories load once at startup and serve synchronous reads from memory.
- Settings use `shared_preferences`; no other data does.
- IDs use UUID v7.
- The app is offline-first. The repository layer will hide local/remote later;
  don't add persistence ad hoc.

## Guardrails

- No `ScoringRule` abstraction until a third rule set exists.
- The database is pre-release; no migrations beyond schema version 1.
