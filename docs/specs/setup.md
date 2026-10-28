# Setup — home, setup page, config, player picking

Owns: home grid, setup state/validation, player selection, config panel.

## Home

`HomePage` renders a `ModeCard` (in `features/home/widgets/`) per
`MatchMode.values`; icons are mapped by a private extension in
`home_page.dart`.

- Content is capped at 600 px wide; the grid uses 2 columns at/above
  `LayoutBreakpoints.compact`, else 1.
- `ModeCard` is a `Semantics(button: true)` card with an `InkWell`.
- Tournament is a no-op; other modes push `MatchSetupPage(mode: mode)`.

## Setup page

Thin page: providers, layout, routing.

- Provides `PlayerRepository` and `MatchSetupNotifier` (feature-local).
- AppBar: `'${mode.displayName} Match'`, no back button.
- Scroll area holds `PlayerPanel` and `MatchConfigPanel`; `SetupActions`
  (Cancel / Start Match) stays pinned below.
- Tapping a slot opens `PlayerPickerDialog`; a non-null result calls
  `setPlayer(side, slot, player)`.
- Start: `validatePlayers()`; on error show a snackbar (no inline errors),
  otherwise `buildMatch()` and push `MatchPage`.
- Cancel pops.

## MatchSetupNotifier

Constructed with `mode`; `players` is `sideCount` lists of `playersPerSide`
nulls. Defaults: `eightBall`, `winnerBreak`, `raceTo 5`, `innings 25`.

- `breakFormat` assigns; `raceTo` and `innings` clamp to `MatchLimits` and
  early-return when unchanged.
- `setPlayer` / `clearPlayer` silently ignore out-of-range indexes.
- `validatePlayers` returns one of these exact messages or null:
  - `'Players incomplete, please fill all player slots.'`
  - `'Duplicate players detected, please pick different players.'`
- `buildMatch` throws `StateError` when invalid; otherwise builds a straight
  pool `inningsLimit` only where relevant, converts non-null players to
  `MatchSide`s, and creates a `created` match with a UUID v7.

`gameType` reset (one notify, no restore):

- Entering straight pool: `raceTo = 75`, `breakFormat = alternateBreak`.
- Leaving straight pool: `raceTo = 5`.
- Between rotation games: `raceTo` untouched.
- `innings` never changes; re-entering straight pool always gives 75.

## PlayerPanel

`LayoutBuilder`: below `compact` the sides stack vertically; otherwise they
sit in a `Row` of `Expanded` blocks. There is no doubles special case, so
doubles' two slots stay vertically stacked inside each side.

- Labels: `'Player N'` for singles/three-player, `'Team A'`/`'Team B'` for
  doubles. `tournament` never reaches setup and throws.
- Each slot shows `PlayerSlot`: empty shows a plus and `'Pick player'`;
  filled shows the club line above the name. The club line is always
  rendered, empty when `clubName` is null.

## PlayerPickerDialog

- **Club filter**: unique non-null club names, sorted case-insensitively,
  with an `All` entry. Searchable dropdown.
- **Search**: matches first, last, or full name, case-insensitive, trimmed;
  does not match club. Key `player-search` (the dropdown has its own field).
- **List**: rows show `countryCode` as the leading identifier and
  `fullName`; tapping pops the player. Empty result shows `'No players'`.
- Cancel pops null. Duplicates are pickable here but rejected by
  `validatePlayers` at start.
- Country in the row and club in the filter are intentionally independent.

## MatchConfigPanel

`LayoutBuilder` on the panel width:

- Below `wide` (800): one vertical stack; hidden controls use default
  `Visibility`, so they take no height.
- At/above `wide`: two columns — selectors left, steppers right — and hidden
  controls use `maintainSize`, `maintainAnimation`, `maintainState`.
- Break format is hidden (not disabled) for straight pool; innings is shown
  only for straight pool.
- Because breakpoints see inner constraints, outer padding shifts the width
  at which they fire (this panel's wide layout starts around 832 viewport px).

Selectors use `SegmentedButton` with game types labelled by `shortName`.
`NumberStepper` provides `-10`, `-1`, `+1`, `+10` with long-press repeat that
stops at the bounds; optional labels sit inline around the value
(`'Race to 5'`, `'25 innings'`).
