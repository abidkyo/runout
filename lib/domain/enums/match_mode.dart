/// The format of a match in terms of player count and pairing.
enum MatchMode {
  /// One player against one player.
  singles,

  /// Two players against two players.
  doubles,

  /// Three players, each playing individually.
  threePlayer,

  /// Tournament bracket mode, driven by the manager app.
  tournament,
  ;

  /// Number of sides in a match of this mode.
  ///
  /// Returns 0 for [MatchMode.tournament], since tournament matches
  /// are configured by the manager app, not the setup page.
  int get sideCount {
    switch (this) {
      case MatchMode.singles:
      case MatchMode.doubles:
        return 2;
      case MatchMode.threePlayer:
        return 3;
      case MatchMode.tournament:
        return 0;
    }
  }

  /// Number of players per side in this mode.
  ///
  /// Returns 0 for [MatchMode.tournament].
  int get playersPerSide {
    switch (this) {
      case MatchMode.singles:
      case MatchMode.threePlayer:
        return 1;
      case MatchMode.doubles:
        return 2;
      case MatchMode.tournament:
        return 0;
    }
  }
}
