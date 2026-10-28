# Architecture

Owns: folders, layer rules, state, app composition.

## Layout

```text
lib/
├── main.dart                     # runApp
├── app.dart                      # RunoutApp: MaterialApp, theme, text scale
├── core/                         # cross-cutting, no feature knowledge
│   ├── constants/                # LayoutBreakpoints, MatchDefaults, MatchLimits
│   ├── theme/                    # AppTheme, AppTextTheme extension
│   ├── errors/                   # reserved (empty)
│   └── utils/                    # reserved (empty)
├── data/
│   ├── local/                    # reserved (empty)
│   ├── remote/                   # reserved (empty)
│   └── repositories/             # PlayerRepository (in-memory)
├── domain/                       # pure business logic
│   ├── models/                   # Player, MatchSide, MatchConfig, Match
│   └── enums/                    # MatchMode, GameType, BreakFormat, Foul
├── features/                     # one folder per screen/flow
│   ├── home/                     # HomePage, widgets/
│   ├── match_setup/              # page, notifier, widgets/
│   ├── match/                    # page, notifiers, widgets/
│   ├── tournament/               # empty (placeholder)
│   └── manager_link/             # empty (placeholder)
└── shared/
    └── widgets/                  # ConfirmDialog (+ showConfirmDialog)

test/
├── unit/                         # features/..., helpers/factories.dart
└── widget/                       # features/..., shared/
```

Features now: `home`, `match_setup`, `match`; `tournament` and
`manager_link` are empty placeholders.

## Layer rules

- `features/` → `domain/`, `data/`, `shared/`, `core/`.
- `data/` → `domain/`, `core/`. Never `features/`.
- `domain/` → no app imports, no Flutter. Pure Dart.
- `shared/` → `core/`, `domain/`. Never `features/`.

There is no import linter; enforce by review.

## Feature folders

- Public widgets live in `features/<feature>/widgets/`; pages and notifiers
  stay at the feature root.
- Pages are thin: create providers, route, and delegate layout.
- One-off subwidgets stay private (`_Name`) in the using file.

## Composition

- `RunoutApp` returns a `MaterialApp`: light theme, no router/named routes.
  Navigation is `Navigator.push(MaterialPageRoute(...))`, `pop`, or
  `popUntil(route.isFirst)`.
- Text scale is one `MediaQuery` override in `app.dart`
  (`TextScaler.linear(1.5)`); system scale is intentionally ignored.
- Targets all Flutter platforms. No platform-specific branches, conditional
  imports, or `dart:io` in app code.
- `MatchPage` receives the built `Match`; it does not read setup state.

## State

- Provider only. No Riverpod, no Bloc, no global state.
- Notifiers are `ChangeNotifier`, one per screen/flow: `MatchSetupNotifier`,
  `MatchNotifier`, and `MatchTimerNotifier` (derived from `MatchNotifier`).
- Providers are created at page level. `MatchSetupPage` provides
  `PlayerRepository` and `MatchSetupNotifier`; `MatchPage` provides
  `MatchNotifier` and `MatchTimerNotifier`.
- Use `context.watch` to rebuild, `context.read` for actions, and
  `Consumer`/`Selector` for partial rebuilds. Don't use `listen` directly.
- Undo/redo is two `List<Match>` snapshot stacks. `Match` is immutable, so
  snapshots are cheap.
- The UI resets one-shot notifier flags (`notifyExtension`,
  `notifyThreeFouls`, `askToContinue`) after reading them.

## Data

- `PlayerRepository` is the only repository: 10 hardcoded professional
  players, provided per setup page. No DB, network, or serialization yet.
- Offline-first is the intended direction; the repository layer will hide
  local/remote later. Don't add persistence ad hoc.
- IDs use UUID v7 (`Uuid().v7()`).

## Scope guards

- No `ScoringRule` abstraction yet. Rotation and straight-pool rules live in
  `MatchNotifier`; extract only when a third rule set appears.
- Timer is UI-only: `startedAt`/`endedAt` are domain data; ticking and
  duration are derived.
- `shared_preferences` deliberately absent until there is a real setting.
