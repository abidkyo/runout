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

- `RunoutApp` owns the settings notifier and passes the selected theme and
  color to `MaterialApp`. Theme changes apply immediately.
- `RunoutApp` provides the in-memory `PlayerRepository` and `MatchRepository`
  once at the root through `AppProviders`.
- The Home shell uses a compact AppBar and `NavigationBar`; wide layouts use a
  sidebar. Settings is a shell tab.
- `MaterialApp` uses light and dark themes selected by settings; no router or
  named routes.
- `MatchPage` owns match actions; the match header, side cards, controls bar,
  and buttons are presentational.
- Targets all Flutter platforms. No platform-specific branches, conditional
  imports, or `dart:io`.

## State and data

- Provider only, no global state. Feature notifiers are `ChangeNotifier`;
  providers are created at page level.
- Home reads `MatchRepository` directly; `getFinished(limit:)` supplies the
  recent cap. Repository delete/restore remain for the future `MatchDetailPage`.
- Use `context.watch` to rebuild, `context.read` for actions,
  `Consumer`/`Selector` for partial rebuilds.
- Undo/redo stores immutable `Match` snapshots in two stacks.
- `PlayerRepository` and `MatchRepository` are in-memory only. Settings are
  persisted with `shared_preferences`. No DB or network yet.
- Offline-first is the intended direction; the repository layer will hide
  local/remote later. Don't add persistence ad hoc.
- IDs use UUID v7.

## Scope guards

- No `ScoringRule` abstraction yet; extract only when a third rule set appears.
- Timer is UI-only; duration is derived, never stored.
- `shared_preferences` is limited to app settings; match and player persistence
  stays deferred.
