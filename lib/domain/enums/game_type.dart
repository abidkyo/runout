/// The billiard game variant being played.
enum GameType {
  eightBall,
  nineBall,
  tenBall,
  straightPool,
  ;

  String get displayName => switch (this) {
    .eightBall => '8 Ball',
    .nineBall => '9 Ball',
    .tenBall => '10 Ball',
    .straightPool => 'Straight Pool',
  };
}
