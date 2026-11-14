import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runout/domain/models/player.dart';

part 'match_side.freezed.dart';

/// A side in a match — the unit that shares a score.
///
/// - Singles: one side per player.
/// - Doubles: one side per team (two players).
/// - Three-player: one side per player.
@freezed
class MatchSide with _$MatchSide {
  const new({
    required this.players,
    this.score = 0,
    this.innings = 0,
    this.highRun = 0,
    this.consecutiveFouls = 0,
  }) : assert(players.length > 0, 'A side must have at least one player.');

  /// Players belonging to this side. Length is 1 or 2.
  final List<Player> players;

  /// Points scored by this side.
  final int score;

  /// Visits counted for this side.
  final int innings;

  /// Highest single-visit score for this side.
  final int highRun;

  /// Consecutive standard-foul count for this side.
  ///
  /// Straight pool only; stays zero for 8/9/10-ball.
  final int consecutiveFouls;
}
