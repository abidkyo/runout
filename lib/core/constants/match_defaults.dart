/// Domain defaults for match.
class MatchDefaults {
  new _();

  /// Points needed to win a rotation game by default.
  static const int raceTo = 5;

  /// Points needed to win straight pool by default.
  static const int straightPoolRaceTo = 75;

  /// Default innings limit for straight pool.
  static const int inningsLimit = 25;

  /// Innings added to break a tie.
  static const int inningsExtension = 5;

  /// Penalty points for three-fouls.
  static const int threeFoulsPenalty = 15;
}
