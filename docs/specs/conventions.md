# Conventions

## Files

- Separate code sections with
  `// ---------------------------------------------------------------------------`.
- App configuration enums live with their config in `core/constants/`.
- Test files mirror `lib/` by feature; the `widgets/` subfolder is not mirrored.

## File layout

Order inside a file:

1. types (enums, small file-local models),
2. static content (constants),
3. exported widget/class,
4. private subwidgets,
5. helpers (extensions, top-level functions).

## Theme

- `context.textTheme` / `context.colors` come from `theme_extension.dart`.
- Custom text styles are defined in `AppTextTheme`.
- Colors used are defined in `AppColorScheme`.

## Naming

| Thing | Form |
| --- | --- |
| Notifier | `XNotifier` |
| Private widget | `_WidgetName` in the same file |
| Public widget | own file in `widgets/` |
| Dialog | `XDialog` in `widgets/` (shared → `shared/widgets/`) |
| Constant / enum value | `lowerCamelCase` |
| Boolean | `isX`, `hasX`, `canX` |
| Test file | `<subject>_test.dart` |

## Widgets and layout

- Never return a widget from a method; extract a widget class.

## Errors

Choose by reachability:

| Mechanism | Use for | Example |
| --- | --- | --- |
| `StateError` | reachable by a correct program | `buildMatch()` with empty players |
| `assert` + early return | only incorrect code can produce it | bad index, negative points |
| silent early return | normal precondition not met | `incrementScore` while not playing |

Never throw in release paths; tests verify asserts, not release returns.

## Semantics

- Custom state-bearing surfaces need an explicit `Semantics` wrapper.
- Labels describe state only, never content a child already shows.

## Comments

Explain why or a non-obvious contract, not what the code does. Update or delete
stale comments in the same change; no commented-out code or changelogs.

## Testing

- Unit tests cover domain and notifiers. Use `fake_async` for timers; dispose
  notifiers that own timers or listeners.
- `test/unit/helpers/factories.dart` provides builders. Use a factory when its
  defaults are the point; otherwise construct the object directly.
- Widget tests pump the smallest widget owning the contract. For width
  contracts, wrap in `Center(SizedBox(width: X))` and test at the threshold and
  threshold + 1.
- Stateful widgets use a `_Host` that owns the value and rebuilds on change.
- Assert behavior and user-visible outcomes. Add keys only when a finder is
  otherwise ambiguous.
- `DropdownMenu`: tap the menu itself; use
  `find.widgetWithText(MenuItemButton, '<label>')` for entries.
- Avoid `find.text('')`; empty `EditableText` internals also render text.
- Semantics: use `tester.ensureSemantics()` and assert state labels.
- Responsive tests set `physicalSize` with `devicePixelRatio = 1` and reset in
  `addTearDown`. Dialogs tapping below the fold need a taller viewport or
  `ensureVisible`.
- No mocking package; prefer real objects, factories, and hosts.
