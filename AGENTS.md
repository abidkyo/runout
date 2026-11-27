# Runout — Agent Guide

A cross-platform billiard scoring app built with Flutter. Provider is the only
state-management solution. Web is the primary development target.

Maintain compatibility with Android, iOS, Linux, macOS, and Windows.

## Read This First

- Specifications are the source of truth. If code and specs disagree, stop and
  ask rather than choosing silently.
- Read only the specifications relevant to the task.
- Don't read `lib/` end to end. Use glob/grep to locate relevant files.
- Keep responses concise. No preamble, recap, or code unless requested.

| Task                                  | Read                         |
| ------------------------------------- | ---------------------------- |
| Scope, status, roadmap                | `docs/specs/product.md`      |
| Layers, folders, providers, app shell | `docs/specs/architecture.md` |
| Domain rules and scoring              | `docs/specs/domain.md`       |
| Setup and match UI/UX                 | `docs/specs/ui.md`           |
| Naming, errors, tests                 | `docs/specs/conventions.md`  |

## Architecture & Coding Rules

- Follow the existing architecture and project conventions.
- Make the smallest change that satisfies the task. Don't overengineer: no
  speculative abstractions, state, or configuration.
- Keep business logic separate from UI.
- Respect layer boundaries:
  - `features/` → `domain/`, `data/`, `shared/`, `core/`
  - `data/` → `domain/`, `core/`
  - `domain/` → pure Dart; no Flutter or app dependencies
  - `shared/` → `core/`, `domain/`
  - Never import `features/` from `data/` or `shared/`.
- Use Provider exclusively for state management. No Riverpod or Bloc.
- Notifiers extend `ChangeNotifier`. Feature notifiers use page-level providers;
  app repositories are provided once at the root via `AppProviders`.
- Use `context.watch`, `context.read`, `Consumer`, or `Selector`.
- Extract reusable widgets into widget classes. Don't return widgets from
  methods.
- Keep feature widgets under `features/<feature>/widgets/`.
- Use `package:runout/...` imports, never relative imports.
- Keep one model per file in `domain/models/` and one enum per file in
  `domain/enums/`.

## Dart & Flutter Conventions

- Follow Dart and Flutter best practices.
- Follow Material 3 and the app's design system. Reuse existing shared widgets.
- Aim for clear, accessible UI/UX: support compact and wide layouts, 2× text
  scale, semantics, and reduced motion.
- Prefer stateless widgets. Add state only when it owns behavior.
- Prefer `const` wherever possible.
- Keep line length at or below 80 characters.
- Use trailing commas for multiline constructs.
- Boolean variables and getters use auxiliary verbs (`isX`, `hasX`, `canX`).
- Notifier setters should return early when the value hasn't changed.
- Use `clock.now()` instead of `DateTime.now()` for testability.
- Handle empty states inside the screen displaying them.
- Domain models use Freezed classic classes; after changing one, run
  `dart run build_runner build`. Never edit `*.freezed.dart` by hand.
- Avoid unnecessary abstractions and dependencies.
- No new dependencies without asking.

## Flutter and Dart Command Execution

Run `flutter` and `dart` directly inside the sandbox: no `sandbox_permissions`,
no approval. Their state outside the workspace (Flutter SDK, pub cache, Dart
tool directories) is already granted, so never escalate them. If one still hits
a write denial, report the path — the host profile needs it in
`sandbox-policy.additionalWritableRoots`.

## Testing & Quality

- Tests are part of completion. Add or update tests in the corresponding test
  directory.
- Never delete tests just to make a build pass.
- Run the following checks before considering a task complete:

```bash
dart format .
flutter analyze
flutter test
```

- Test the relevant functionality, including edge cases.
- Prioritize Web during development and testing while maintaining cross-platform
  compatibility.

## Development Workflow

1. Work on the current branch. Don't create, switch, or delete branches unless
   asked.
2. Read the relevant specifications and source files.
3. Implement the changes that satisfy the task.
4. Add or update corresponding tests.
5. Run formatting, analysis, and tests.
6. Update only the affected specification sections when necessary.
7. Commit logical changes. The user reviews commits and may rebase or amend
   them; never rewrite history or force-push unless asked.

## Skills

- Load `.agents/skills/commit` before committing.
- Load `.agents/skills/format-markdown` before editing Markdown.
- Load the matching Flutter skill from `$HOME/.agents/skills/` before
  Flutter-specific work.

## Specification Maintenance

- Keep one topic per specification file.
- Keep specs concise: document contracts, decisions, and rationale, not code
  details.
- Don't rewrite unrelated specifications.
- Use `git log` as the project changelog.
