# UI/UX

## Home

- The home shell uses a compact AppBar with the app name and slogan, plus a
  bottom `NavigationBar`; wide layouts use a sidebar.
- The hero is the primary action. New Match opens setup in Singles mode.
- In-progress matches are listed under “Continue Matches”; the section is
  hidden entirely when none are playing.
- Recent finished matches are capped at 10. “See all” switches to the Matches
  tab.
- Cards show the match date; created matches show “Not started”. Deleting a
  match is deferred to the future `MatchDetailPage`.
- Players and Settings are placeholder tabs until their features land.
- Home and Match History avoid fixed heights. Layouts stay usable at 1.5× and
  2× text scale; the compact AppBar grows with the text scale and cards avoid
  fixed trailing widths.

## Match History

- The Matches tab lists finished matches only, newest first.
- History cards are display-only; there is no detail page yet.
- An empty history shows a single empty state.

## Match Setup

- Setup is a single scrolling panel: an in-page “New Match” header, one setup
  card, and pinned bottom actions. Page content is capped at
  `LayoutBreakpoints.contentMax` (1200).
- Home opens setup in Singles mode; mode is selectable in-page. Changing mode keeps
  players in slots that still exist and drops removed slots.
- Player slots have player/team labels on top and open the picker on tap.
- Duplicate players are allowed in the picker and rejected by validation at
  start: keep the picker simple, block the real mistake at the last gate.
- Switching game type resets straight-pool defaults (`raceTo`, break format)
  and does not restore previous values.
- Break format is hidden, not disabled, for straight pool; innings is shown
  only for straight pool. Hidden sections collapse.
- There is no doubles special case; sides follow the compact breakpoint.
- Setup stays usable at 375px and at 1.5×/2× text scale; the stepper
  and bottom actions wrap instead of clipping.

## Match

- The match page is a full-screen scoreboard: an in-page header, side cards that
  fill the available height, and a bottom action bar. It does not scroll and
  does not cap its content width.
- The header shows the game, the race target (plus the innings limit for
  straight pool), and the elapsed time.
- At compact width every side stacks; at wide width sides sit side by side.
- Cards show the players, a score that scales to fill its card, and
  straight-pool stats. Created matches show “Who breaks?”. The winner card gets
  a trophy.
- The whole side card is the tap target. The action depends on status: breaker
  selection, score increment, or the straight-pool scoring dialog; finished
  cards are not tappable.
- In straight pool, every side card opens the scoring dialog while playing. The
  dialog always scores the current side and shows that side's player names.
- The bottom bar has undo/redo, straight-pool tiles on wide layouts, and
  Discard/Setup/Home. The compact bar uses icon buttons without straight-pool
  action tiles; compact straight-pool scoring uses the side cards.
- Finished matches show no straight-pool actions.
- Exit to home does not confirm; the current match is preserved for saving.
- Setup confirms while playing, returns to setup, and discards the current
  match. Created matches skip the confirmation.
- Discard confirms while playing, returns home, and discards the current match.
  Created matches skip the confirmation.
- The target-reached prompt ignores barrier taps so an outside tap cannot
  choose `End`.
- A target reached on a kept turn asks whether to continue. Ending re-applies the
  score as a visit-ending score.
- The page stays usable at 375px and at 1.5×/2× text scale; labels ellipsize or
  scale down instead of overflowing.
- Custom state surfaces need explicit semantics; labels describe state
  (`Winner`/`Breaking`/`Loser`) only, never content.
