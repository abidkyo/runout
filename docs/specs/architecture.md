# Architecture

## Layout

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/
│   └── theme/
├── data/
│   └── repositories/
├── domain/
│   ├── enums/
│   └── models/
├── features/
│   ├── home/
│   ├── manager_link/
│   ├── match/
│   ├── match_setup/
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
- Pages are thin: create providers, route, and delegate layout.
- One-off subwidgets stay private in the using file.

## Composition

- `MaterialApp` with the light theme; no router or named routes.
- Targets all Flutter platforms. No platform-specific branches, conditional
  imports, or `dart:io`.

## State and data

- Provider only, no global state. Notifiers are `ChangeNotifier`; providers
  are created at page level.
- Use `context.watch` to rebuild, `context.read` for actions,
  `Consumer`/`Selector` for partial rebuilds.
- Undo/redo stores immutable `Match` snapshots in two stacks.
- `PlayerRepository` is in-memory only. No DB, network, or serialization yet.
- Offline-first is the intended direction; the repository layer will hide
  local/remote later. Don't add persistence ad hoc.
- IDs use UUID v7.

## Scope guards

- No `ScoringRule` abstraction yet; extract only when a third rule set appears.
- Timer is UI-only; duration is derived, never stored.
- `shared_preferences` stays absent until there is a real setting.
