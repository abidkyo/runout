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

  String get displayName => switch (this) {
    .singles => 'Singles',
    .doubles => 'Doubles',
    .threePlayer => 'Three Players',
    .tournament => 'Tournament',
  };

  /// Number of sides in a match of this mode.
  ///
  /// Returns 0 for [MatchMode.tournament], since tournament matches
  /// are configured by the manager app, not the setup page.
  int get sideCount => switch (this) {
    .singles || .doubles => 2,
    .threePlayer => 3,
    .tournament => 0,
  };

  /// Number of players per side in this mode.
  ///
  /// Returns 0 for [MatchMode.tournament].
  int get playersPerSide => switch (this) {
    .singles || .threePlayer => 1,
    .doubles => 2,
    .tournament => 0,
  };
}
