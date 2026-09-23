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
}
