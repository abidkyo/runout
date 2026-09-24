/// Determines which side breaks each rack.
enum BreakFormat {
  /// The side that won the previous rack breaks the next one.
  winnerBreak,

  /// Sides alternate breaking each rack.
  alternateBreak,
}
