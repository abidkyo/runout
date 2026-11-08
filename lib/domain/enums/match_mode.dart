/// The format of a match in terms of player count and pairing.
enum MatchMode {
  /// One player against one player.
  singles,

  /// Two players against two players.
  doubles,

  /// Three players, each playing individually.
  threePlayer,
  ;

  String get displayName => switch (this) {
    .singles => 'Singles',
    .doubles => 'Doubles',
    .threePlayer => 'Three Players',
  };

  /// Number of sides in a match of this mode.
  int get sideCount => switch (this) {
    .singles || .doubles => 2,
    .threePlayer => 3,
  };

  /// Number of players per side in this mode.
  int get playersPerSide => switch (this) {
    .singles || .threePlayer => 1,
    .doubles => 2,
  };
}
