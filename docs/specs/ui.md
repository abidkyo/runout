# UI/UX

## Layout

All screens stay usable at 375px width and up to 2× text scale. Content is
capped at the same maximum width across screens. Text-bearing surfaces avoid
fixed heights.

## Home

- A short header with the app name and slogan sits above a bottom navigation bar
  when compact or a sidebar when wide. Settings is a tab.
- The hero “New Match” action opens setup in Singles mode.
- “Continue Matches” lists in-progress matches and hides when empty.
- “Recent Matches” shows the latest 10 finished matches; “See all” opens Match
  History.
- Both lists refresh when a match is saved, finished, or discarded.
- Cards show the match date; unstarted matches show “Not started”.
- Players is a placeholder tab until its feature lands.
- A fresh install shows empty states; there is no sample data.
- If storage fails to load, one snackbar says changes will not be saved.

## Match History

- Lists finished matches, newest first.
- Cards are display-only; there is no detail page yet.
- An empty history shows one empty state.

## Settings

- One appearance card with Theme, Color, and Text Size.
- Theme: System, Light, or Dark. Color: Blue or Green.
- Text Size: 100–150% in 5% steps. It applies across the app and overrides the
  system scale.
- Defaults: System, Blue, 100%.
- Changes apply and persist immediately; there is no Save action.
- Text Size shows the current percentage and a match-card preview.
- Choices fill the row when wide and stack when compact.

## About

- Opens from the home app bar on compact layouts and from the sidebar footer on
  wide layouts.
- Shows the Runout logo, name, slogan, description, version, third-party
  licenses, data/privacy policy, and the portfolio address.
- Licenses opens Flutter's built-in license page; the privacy policy stays
  inline.
- The portfolio address is selectable text.

## Match Setup

- A single scrolling panel with an in-page header, one setup card, and pinned
  bottom actions.
- Setup opens in Singles; mode is selectable. Changing mode keeps players in
  slots that still exist.
- Player slots show player or team labels and open the player picker on tap.
- Duplicate players are allowed in the picker and rejected at start.
- Known players come from the database, sorted by name; new players are saved on
  creation.
- Switching game type resets straight-pool defaults (race target and break
  format).
- Break format is hidden for straight pool; innings is shown only for straight
  pool.
- Sides follow the compact breakpoint; there is no doubles special case.
- The stepper and bottom actions wrap instead of clipping.

## Match

- A full-screen scoreboard: header, side cards that fill the height, and a
  bottom action bar. It does not scroll or cap its content width.
- The header shows the game, race target (and innings limit for straight pool),
  and elapsed play time excluding pauses.
- Sides stack when compact and sit side by side when wide.
- Cards show players and score; straight pool adds stats. Created matches ask
  “Who breaks?”. The winner card gets a trophy.
- When a winner is decided during play, a one-shot confetti burst plays. It is
  decorative and skipped when reduced motion is requested. Opening a finished
  match does not replay it.
- The whole side card is tappable: breaker selection, score increment, or the
  straight-pool scoring dialog. Finished cards are not tappable.
- In straight pool, side cards open the scoring dialog, which scores the current
  side and shows that side's players.
- The bottom bar has undo/redo, straight-pool tiles when wide, and
  Discard/Setup/Home. Compact layouts use icon buttons and score straight pool
  through the side cards.
- Finished matches show no straight-pool actions.
- Home does not confirm: it saves and pauses the match, and opening it again
  resumes it. Elapsed time excludes the pause.
- System back pops normally when the match is created or finished. While
  playing, it acts like Home: pause and return home.
- Setup is hidden when a match was opened from Home (Continue), since there is
  no setup route to return to.
- Setup confirms while playing, returns to setup, and discards the match.
  Created matches skip the confirmation.
- Discard confirms while playing, returns home, and deletes the match. Created
  matches skip the confirmation. A failed delete does not block navigation and
  shows a snackbar.
- The target-reached prompt ignores barrier taps so an outside tap cannot choose
  End.
- A target reached on a kept turn asks whether to continue; ending applies the
  score as a visit-ending score.
- Labels ellipsize or scale instead of overflowing.
- Custom state labels describe state only (`Winner`, `Breaking`, `Loser`), never
  content a child already shows.
