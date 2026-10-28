# Testing

Owns: test layout, commands, factories, widget-test practices.
Behavior under test: `scoring.md`, `setup.md`, `match-ui.md`.

## Layout

Mirror `lib/` by feature, not by its `widgets/` subfolder:

```text
test/
├── unit/
│   ├── helpers/factories.dart
│   └── features/<feature>/<subject>_test.dart
└── widget/
    ├── features/<feature>/<subject>_test.dart
    └── shared/<subject>_test.dart
```

`test/integration/` does not exist; add it only with a real integration test.

## Commands

```bash
flutter test
flutter test test/unit/features/match/match_notifier_test.dart
flutter test --plain-name 'returns zero'
```

Done means `dart format . && flutter analyze && flutter test`.

## Unit tests

- Cover domain logic and notifiers; `MatchNotifier` and
  `MatchSetupNotifier` hold most of the suite.
- Use `fake_async` for timer tests. Domain code uses `clock.now()`, so tests
  control time rather than sleeping.
- Dispose notifiers that were listened to or own timers.
- Debug-only guards are tested by expecting the assert; release early returns
  are not reachable in `flutter test`.

### Factories

`test/unit/helpers/factories.dart` provides `makePlayer`, `makeSide`,
`makeConfig`, `makeMatch`, `makeStraightPoolConfig`, and
`makeStraightPoolMatch`. Defaults: 8-ball, alternate break, race to 10;
straight pool uses `inningsLimit: 1`.

Use a factory when its defaults are the point. When the test is about the
object's content, construct it directly with `const Player(...)` and so on.
Test names describe behavior.

## Widget tests

- Pump the smallest widget that owns the contract; add
  `MaterialApp`/`Scaffold` only when needed.
- Width contracts: pump inside `Center(SizedBox(width: X))`, not inside
  `AppBar`/`Card`, so the widget sees the tested width. Test boundaries at
  the threshold and threshold + 1.
- Stateful widgets: use a `_Host` that owns the value and rebuilds on
  `onChanged`. If the test needs the state object, have the host return
  `(Notifier, Widget)`.
- Assert behavior, not Flutter. Prefer `find.text`/`find.byIcon`; assert a
  `ButtonStyle` only when the style is the contract.
- Callback tests assert exact counts and cross-callback zero.
- Keys are added only when the finder is otherwise ambiguous:
  `player-search`, `break-format-visibility`, `innings-visibility`,
  `straight-pool-actions-visibility`, `turn-selector-visibility`,
  `score-text`, `break-text`.
- `DropdownMenu`: tap the widget itself, not its label; select entries with
  `find.widgetWithText(MenuItemButton, '<label>')`.
- Avoid `find.text('')`; empty `EditableText` internals also render text.
- Semantics: wrap with `tester.ensureSemantics()` / `handle.dispose()`, then
  assert state labels via `tester.getSemantics(...)`. Don't assert Flutter's
  semantics plumbing.

## Viewports

- Default surface is 800×600. Responsive tests set
  `physicalSize = Size(width, 600)` with `devicePixelRatio = 1` and reset in
  `addTearDown`.
- Test around the breakpoint (`wide ± 100`), not at the default width.
- Dialogs that tap below the fold need a taller viewport or
  `ensureVisible`; otherwise the tap hits the modal barrier and only warns.

## Structure

- Split rendering/style from flow (`showDialog`/`pop`) into groups.
- Navigation flows use a small stub route rather than mocking the navigator.
- No mocking package: prefer real objects, factories, and hosts.
