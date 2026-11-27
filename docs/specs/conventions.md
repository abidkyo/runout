# Conventions

## Files

- File order: types, constants, public widget or class, private widgets, then
  helpers.
- Test files mirror `lib/` by feature; the `widgets/` folder is not mirrored.

## Naming

| Thing                  | Form                                                 |
| ---------------------- | ---------------------------------------------------- |
| Notifier               | `XNotifier`                                          |
| Private widget         | `_WidgetName` in the same file                       |
| Public widget          | own file in `widgets/`                               |
| Dialog                 | `XDialog` in `widgets/` (shared → `shared/widgets/`) |
| Constant or enum value | `lowerCamelCase`                                     |
| Boolean                | `isX`, `hasX`, `canX`                                |
| Test file              | `<subject>_test.dart`                                |

## Widgets

- Never return a widget from a method; extract a widget class.
- Custom state-bearing surfaces need an explicit `Semantics` wrapper. Labels
  describe state only, never content a child already shows.
- Text-bearing surfaces avoid fixed heights; content sizes itself or scrolls.
- Use Material text roles instead of hardcoded font sizes. Scores use tabular
  figures.

## Errors

Choose by reachability:

| Mechanism               | Use for                            | Example                           |
| ----------------------- | ---------------------------------- | --------------------------------- |
| `StateError`            | reachable by a correct program     | `buildMatch()` with empty players |
| `assert` + early return | only incorrect code can produce it | bad index, negative points        |
| silent early return     | normal precondition not met        | `scoreRack` while not playing     |

Never throw in release paths. Tests verify asserts, not release returns.

## Feedback

- Use `showAppSnackBar` for one-off messages; it needs no context.
- It shows the close icon only when no action is supplied.
- Dialog failures stay inline; a snackbar behind a modal barrier is invisible.
- Tests that assert a snackbar must attach the app-level messenger key to their
  `MaterialApp`.

## Comments

Explain why or a non-obvious contract, not what the code does. No stale
comments, changelogs, or commented-out code.

## Testing

- Unit tests cover domain and notifiers. Use `fake_async` for timers and dispose
  notifiers that own timers.
- Prefer factories when their defaults are the point; otherwise construct the
  object directly.
- Widget tests pump the smallest widget owning the contract. Test width
  contracts at the threshold and the threshold plus one.
- Stateful test hosts own the value and rebuild on change.
- Assert behavior and user-visible outcomes. Add keys only when a finder is
  otherwise ambiguous.
- Use `ensureSemantics()` to assert state labels.
- Responsive tests set `physicalSize` with `devicePixelRatio = 1` and reset it
  in `addTearDown`.
- No mocking package; prefer real objects, factories, and hosts.
