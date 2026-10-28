# Runout — Agent Guide

Billiard scoring app. Flutter, Provider-only. Targets Android, iOS, web,
Linux, macOS, and Windows.

## Read this first

- Specs are the source of truth. If code and spec disagree, stop and ask — don't pick one silently.
- Don't read every spec. Read only the rows matching the task.
- Don't read `lib/` end to end. Use glob/grep, then read the files named by the spec.
- Answer terse: no preamble, no recap, no code unless asked.

| Task touches | Read |
| --- | --- |
| Scope, status, roadmap, open questions | `docs/specs/product.md` |
| Layers, folders, providers, app shell | `docs/specs/architecture.md` |
| Models, enums, constants, `Match` fields | `docs/specs/domain.md` |
| Scoring, breaks, undo/redo, straight pool, fouls | `docs/specs/scoring.md` |
| Home, setup page, config panel, player picker | `docs/specs/setup.md` |
| Match screen, cards, dialogs, timer, title | `docs/specs/match-ui.md` |
| Style, naming, errors, semantics | `docs/specs/conventions.md` |
| Tests, factories, finders, viewports | `docs/specs/testing.md` |
| Multi-area change | the 2–3 rows it touches; never all |

## Commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter test test/unit/features/match/match_notifier_test.dart
flutter test --plain-name 'returns zero'
flutter run -d chrome
```

Baseline before claiming done: `dart format . && flutter analyze && flutter test`.

## Skills

- `.agents/skills/commit` — load before committing.
- `$HOME/.agents/skills/` — load the matching Flutter skill before Flutter-specific work.

## Hard rules

- **Layer imports.** `features/` → `domain/`, `data/`, `shared/`, `core/`. `data/` → `domain/`, `core/`. `domain/` imports nothing from the app (pure Dart, no Flutter). `shared/` → `core/`, `domain/`. Never import `features/` from `data/` or `shared/`.
- **State management.** Provider only. No Riverpod, no Bloc. Notifiers are `ChangeNotifier`. Providers registered at the feature level, not globally. Use `context.watch` / `context.read` / `Consumer` / `Selector` — not `listen`.
- **Widgets over methods.** Never return a widget from a method. Extract a widget class. Exception: trivial top-level placeholders during scaffolding.
- **File structure.** Order within a file: types (enums, small file-local models), static content (constants), exported widget/class, private subwidgets, helpers (extensions, functions).
- **Feature widgets.** Every feature keeps its widgets under `features/<feature>/widgets/`; pages and notifiers stay at the feature root.
- **Variable naming.** Boolean variables and getters use auxiliary verbs (`isX`, `hasX`, `canX`). Never bare nouns for booleans.
- **`const` everywhere possible.** Constructors, widgets, list literals.
- **Line length.** ≤ 80 columns, trailing comma on multi-line constructs.
- **Empty states** are handled inside the displaying screen, not delegated to a parent.
- **Imports of `lib/` files use `package:runout/...`**, never relative.
- **One model per file** in `domain/models/`. **One enum per file** in `domain/enums/`.
- **Time:** use `clock.now()`, never `DateTime.now()` for easier testing.
- **Error signaling:** `StateError` for reachable-by-correct-program invalid calls. `assert` + early return for invalid-by-incorrect-code calls (out-of-range index, negative points). Never throw in release paths.
- **Setters** on notifiers early-return if the value is unchanged.
- **Tests** are part of done: add/adjust the test in the mirror path. Never delete a test to make a build pass.
- **No new dependencies** without asking.

## Workflow

1. Read the matching spec (table above) and the files it names.
2. Make the smallest change that satisfies the task.
3. Update the mirrored test.
4. Run the baseline command.
5. Update only the affected spec section, in the same change. Don't rewrite other specs, don't add a new spec file, don't paste spec content into the answer.
6. Commit the logical change. The user reviews commits later.

## Spec maintenance

- One topic per file; decisions live next to the feature they explain, not in a separate decisions log.
- Record contracts and rationale the code doesn't show. Don't restate code line by line.
- `git log` is the changelog. Don't add a "recent changes" section.
