# Match UI — page, cards, controls, dialogs

Owns: match screen, side cards, controls, timer, title, dialogs, semantics.
Scoring rules: `scoring.md`; shared style: `conventions.md`.

## MatchPage

`MatchPage(match)` provides `MatchNotifier` and `MatchTimerNotifier`, then
renders `_MatchView`.

- AppBar: `MatchTitle(config)`, centered, no back button, `MatchTimer` in
  the actions.
- Body: `SafeArea` → `Padding(8)` → `Expanded(_ScoreArea)` + `ControlsBar`.
  No scroll.
- Back to setup and exit to home confirm while `status == playing`, both
  destructive:
  - titles: `'Back to setup?'` / `'Exit to home?'`.
  - message: `'The match is still in progress. Leaving will discard the
    current match.'`
  - confirm: `'Leave'`.
  Back to setup pops to setup; exit pops to the first route (home). `created`
  and `finished` skip the prompt.

## _ScoreArea

`LayoutBuilder`: below `compact` the sides stack in a `Column`, else a `Row`,
for every mode. Sides are `Expanded`, so they share space without scrolling.

Tap routing, in order:

1. `created` → `selectBreaker(i)`.
2. straight pool → no tap.
3. `finished` → no tap.
4. otherwise → `incrementScore(i)`.

Each card contains the player names, the score area, and straight-pool stats
when applicable. Before the match starts the score area is `'Who breaks?'`;
afterwards it is a single-line `AutoSizeText` that only shrinks. Stats show
when straight pool and not `created`, with innings clamped to
`effectiveInningsLimit`.

## SideColumn

One side is one tappable `Card`.

- `Semantics(container: true, button: onTap != null, label: ...)` with label
  priority **Winner > Breaking > Loser**; state only, no duplicated name.
- Winner uses the primary-container fill; breaker/winner use a primary
  border; loser is dimmed.
- The whole card owns the `InkWell`; a null `onTap` silently disables it.
  `_ScoreArea` decides the callback.
- Content is a stretched `Column` of `children`; call sites own spacing.

## PlayerNameDisplay

Renders one line per player (not a joined string) so names ellipsize
independently. On the match page the club line is shown only for player 0 and
is always rendered, empty when null, keeping the name band stable. Text size
derives from `MediaQuery.shortestSide`; both lines are single-line, ellipsized,
and centered. `PlayerSlot` follows the same empty-club-line rule.

## StraightPoolStats

`Wrap` of `I`, `HR`, and `Ø` values. Average is `score / innings` to two
decimals, or `0.00` with no innings. Only rendered for straight pool and not
`created`; the high run is live.

## ControlsBar and StraightPoolActions

`ControlsBar` has undo/redo on the left, straight-pool actions in the center,
and restart/exit on the right. Straight-pool actions are hidden (with size
maintained) while not `playing`. `MatchPage` owns the restart/exit dialogs.

`StraightPoolActions`:

- **End visit** → `endVisit()`.
- **Remaining** button showing the count → `RemainingPickerDialog` →
  `scoreRemaining(...)`.
- **New rack** → tap `newRack(1)`; long-press opens `NewRackPickerDialog` →
  `newRack(0|1)`.

After end-visit/remaining actions, `notifyExtension` or `notifyThreeFouls`
shows one snackbar and resets the flag:

- `'Tied — 5 more innings (total N innings)'`
- `'Third fouls — 15 point penalty, re-rack'`

They are mutually exclusive because a third foul forces `keepsTurn`.

**Continue after target:** after `newRack`, `askToContinue` shows
`ConfirmDialog('Target reached.', ..., 'Continue' / 'End')`. `End` undoes the
kept-turn score and re-applies it as a visit-ending score. `Continue` does
nothing. Barrier dismissal is disabled here, so an outside tap cannot choose
`End`. The prompt can appear again later.

## MatchTimer

`MatchTimer` selects `formatted` from `MatchTimerNotifier` and displays it
with tabular figures. The notifier listens to `MatchNotifier`, resyncs only
when `status` changes, ticks once per second while `playing`, and derives
`elapsed` from `startedAt`/`endedAt` (or `clock.now()`). Format is `MM:SS`,
or `HH:MM:SS` at an hour.

## MatchTitle

`LayoutBuilder` inside `AppBar.title`, measuring the slot left after the
leading/actions.

- Rotation: above 280 px, `'<displayName> – Race to <raceTo>'`; otherwise
  `'<displayName> – <raceTo>'`.
- Straight pool: name above 540 px uses `displayName`, else `shortName`;
  above 420 px use `'Race to N'` and `'N innings'`, else bare numbers. Format
  is `'<name> – <race> / <innings>'`.

Separator is an en dash. Boundary tests use the threshold and threshold + 1.

## Dialogs

`RemainingPickerDialog` returns `({remaining, keepsTurn, foul})` or null.

- Title `'How many balls left?'`, scrollable.
- Triangle of balls 2–15. Balls above `remaining`, and all balls while
  `breakFoul` is selected, are disabled. Selecting a number selects 2..N;
  there is no deselect.
- Foul selector: No Foul / Foul, plus Break Foul only when `showBreakFoul`
  (opening break). A non-break foul resets `keepsTurn`.
- Turn selector (Re-break / Continue) is only reachable for a break foul;
  `keepsTurn` is true only for Re-break.
- Cancel pops null; Confirm pops the record.

`NewRackPickerDialog` asks the same title with 0/1 balls; tapping pops
immediately, barrier dismiss pops null.

`ConfirmDialog` is shared: `title`, `message`, required `confirmLabel`,
`cancelLabel` (default `'Cancel'`), and `destructive` for error-colored
confirm text. `showConfirmDialog` owns `showDialog` and maps barrier/null to
`false`; callers can disable barrier dismissal (the target prompt does). The
widget stays navigation-free.

`BallButton` is the shared circular ball control. `width` drives size and
font; `selected` uses primary colors and no border.

## Semantics

- Material buttons get the button role and label for free.
- Custom state surfaces need an explicit `Semantics` wrapper; `InkWell`
  exposes the tap but not `button: true`.
- `SideColumn` is the model case; labels describe state only.

## Responsive notes

- Use `SafeArea` + explicit `Padding`, not `SafeArea(minimum:)` (which is
  zero without insets). Home uses 16 px; match and setup content use 8 px.
- Breakpoints compare `LayoutBuilder` constraints, so surrounding padding
  shifts the viewport width at which they fire.
- Dialog and font decisions use `MediaQuery` where the question is the window
  rather than the widget slot.
