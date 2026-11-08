# Runout — Agent Guide

A cross-platform billiard scoring app built with Flutter.
Provider is the only state-management solution.
Web is the primary development target.

Maintain compatibility with Android, iOS, Linux, macOS, and Windows.

## Read This First

- Specifications are the source of truth. If code and specs disagree, stop and ask rather than choosing silently.
- Read only the specifications relevant to the task.
- Don't read `lib/` end to end. Use glob/grep to locate relevant files.
- Keep responses concise. No preamble, recap, or code unless requested.

| Task | Read |
|---|---|
| Scope, status, roadmap | `docs/specs/product.md` |
| Layers, folders, providers, app shell | `docs/specs/architecture.md` |
| Domain rules and scoring | `docs/specs/domain.md` |
| Setup and match UI/UX | `docs/specs/ui.md` |
| Naming, errors, tests | `docs/specs/conventions.md` |

For changes spanning multiple areas, read only the relevant specifications.

## Architecture & Coding Rules

- Follow the existing architecture and project conventions.
- Keep business logic separate from UI.
- Respect layer boundaries:
  - `features/` → `domain/`, `data/`, `shared/`, `core/`
  - `data/` → `domain/`, `core/`
  - `domain/` → pure Dart; no Flutter or app dependencies
  - `shared/` → `core/`, `domain/`
  - Never import `features/` from `data/` or `shared/`.
- Use Provider exclusively for state management. No Riverpod or Bloc.
- Notifiers extend `ChangeNotifier`. Register providers at feature level.
- Use `context.watch`, `context.read`, `Consumer`, or `Selector`.
- Extract reusable widgets into widget classes. Don't return widgets from methods.
- Keep feature widgets under `features/<feature>/widgets/`.
- Use `package:runout/...` imports, never relative imports.
- Keep one model per file in `domain/models/` and one enum per file in `domain/enums/`.

## Dart & Flutter Conventions

- Follow Dart and Flutter best practices.
- Prefer `const` wherever possible.
- Keep line length at or below 80 characters.
- Use trailing commas for multiline constructs.
- Boolean variables and getters use auxiliary verbs (`isX`, `hasX`, `canX`).
- Notifier setters should return early when the value hasn't changed.
- Use `clock.now()` instead of `DateTime.now()` for testability.
- Handle empty states inside the screen displaying them.
- Avoid unnecessary abstractions and dependencies.
- No new dependencies without asking.

## Testing & Quality

- Tests are part of completion. Add or update tests in the corresponding test directory.
- Never delete tests just to make a build pass.
- Run the following checks before considering a task complete:

```bash
dart format .
flutter analyze
flutter test
```

- Test the relevant functionality, including edge cases.
- Prioritize Web during development and testing while maintaining cross-platform compatibility.

## Development Workflow

1. Read the relevant specifications and source files.
2. Make the smallest change that satisfies the task.
3. Add or update corresponding tests.
4. Run formatting, analysis, and tests.
5. Update only the affected specification sections when necessary.
6. Commit logical changes. The user reviews commits later.

## Skills

- Load `.agents/skills/commit` before committing.
- Load the matching Flutter skill from `$HOME/.agents/skills/` before Flutter-specific work.

## Specification Maintenance

- Keep one topic per specification file.
- Document important contracts, decisions, and rationale that aren't obvious from the code.
- Don't duplicate code documentation in specifications.
- Don't rewrite unrelated specifications.
- Use `git log` as the project changelog.
