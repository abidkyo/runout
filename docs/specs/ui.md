# UI/UX

## Home

- The home shell uses a compact AppBar with the app name and slogan, plus a
  bottom `NavigationBar`; wide layouts use a sidebar.
- The hero is the primary action. New Match opens Singles setup; doubles and
  three-player are not reachable from Home yet.
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

- Duplicate players are allowed in the picker and rejected by validation at
  start: keep the picker simple, block the real mistake at the last gate.
- Search matches names only. Club is a separate filter; the row's country code
  is a scanning identifier, independent of the filter.
- Switching game type resets straight-pool defaults (`raceTo`, break format)
  and does not restore previous values.
- Break format is hidden, not disabled, for straight pool; innings is shown
  only for straight pool.
- There is no doubles special case; sides follow the compact breakpoint.
- Breakpoints measure `LayoutBuilder` constraints, so outer padding shifts the
  viewport width at which they fire.

## Match

- The whole side card is the tap target. The action depends on status:
  breaker selection, score increment, or no tap in straight pool/finished.
- The match page does not scroll; cards share the available space.
- Restart and exit confirm only while playing. The target-reached prompt
  ignores barrier taps so an outside tap cannot choose `End`.
- A target reached on a kept turn asks whether to continue. Ending re-applies
  the score as a visit-ending score.
- The match title measures its own AppBar slot, not the window, because the
  leading/actions reduce the available width.
- Club is shown only for the first player on a side. The club line is always
  rendered, empty when null, to keep the name band height-stable.
- Custom state surfaces need explicit semantics; labels describe state
  (`Winner`/`Breaking`/`Loser`) only, never content.
