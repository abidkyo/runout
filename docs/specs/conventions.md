# Conventions — code, style, errors, semantics

Owns: how code is written. Layers: `architecture.md`; tests: `testing.md`;
short checklist: `AGENTS.md`.

## File layout

Order inside a file:

1. types (enums, small file-local models),
2. static content (constants),
3. exported widget/class,
4. private subwidgets,
5. helpers (extensions, top-level functions).

- One model per file in `domain/models/`; one enum per file in
  `domain/enums/`. Configuration enums live with their config in
  `core/constants/`.
- Public widgets live in the feature's `widgets/`; private `_Name` widgets
  stay in the using file.
- Separate file sections with
  `// ---------------------------------------------------------------------------`
  after imports and between declarations.
- Files are `snake_case.dart`.

## Style

- ≤80 columns; trailing comma on multi-line constructs.
- `const` on constructors, widgets, and list literals where possible.
- Constructor shorthand: `const new(...)`, `new _();`; don't repeat the type.
- Static-only holders use a private constructor.
- Enum-derived getters use `switch` expressions.
- Imports: `dart:` first, then `package:`. All `lib/` imports are
  `package:runout/...`; relative imports are test-only.
- Lints: `very_good_analysis` with strict casts, inference, and raw types.
  Public API docs and Flutter-style TODOs are off.

## Naming

| Thing | Form |
| --- | --- |
| Notifier | `XNotifier` |
| Provider | `ChangeNotifierProvider` (or `Provider` for repos) |
| Private widget | `_WidgetName` in the same file |
| Public widget | own file in `widgets/` |
| Dialog | `XDialog` in `widgets/` (shared → `shared/widgets/`) |
| Enum value | `lowerCamelCase` |
| Constant | `lowerCamelCase` |
| Boolean | `isX`, `hasX`, `canX` — never a bare noun |
| Test file | `<subject>_test.dart` |

## Widgets and layout

- Never return a widget from a method; extract a widget class.
- Empty states belong to the screen/widget that displays the list.
- When a component takes `children`, the call site owns spacing.
- `Card.margin` stays zero; spacing is explicit `Padding`.
- Prefer Material buttons when the thing is a button. Use `InkWell` only for a
  whole custom-shaped surface or gestures buttons don't expose.
- Style buttons with `XButton.styleFrom(...)`, not `ButtonStyle` +
  `WidgetStatePropertyAll`.

## Theme and text

- Material 3, blue seed; light theme is used.
- `AppTextTheme.titleLargeSolid` is the app text style helper. Extensions do
  not resolve transitively — import `app_text_theme.dart` at call sites.
- Text scale is one `MediaQuery` override in `app.dart`
  (`TextScaler.linear(1.5)`); don't re-apply it in widgets.
- Colors come from `colorScheme`; use `withValues(alpha: ...)` for opacity.

## State and errors

- Setters early-return when the value is unchanged.
- One-shot events are public `bool`s the UI resets after reading.
- Error signaling by reachability:

| Mechanism | Use for | Example |
| --- | --- | --- |
| `StateError` | reachable by a correct program | `buildMatch()` with empty players |
| `assert` + early return | only incorrect code can produce it | bad index, negative points |
| silent early return | normal precondition not met | `incrementScore` while not playing |

Never throw in release paths; guards return early. Tests verify the asserts.

## Semantics

- Material buttons get the button role and label for free.
- Custom state-bearing surfaces need an explicit `Semantics` wrapper;
  `InkWell` provides the tap but not `button: true`.
- Labels describe state only (`Winner`/`Breaking`/`Loser`), not content that a
  child already shows.
- `ModeCard` and `SideColumn` are the existing examples.

## Comments

- Explain why or a non-obvious contract; don't restate code. Public
  classes/members get a short doc comment.
- No commented-out code or changelog comments.
- Update or delete a stale comment in the same change.
