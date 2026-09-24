import 'package:meta/meta.dart';
import 'package:runout/domain/models/player.dart';

/// A side in a match — the unit that shares a score.
///
/// - Singles: one side per player.
/// - Doubles: one side per team (two players).
/// - Three-player: one side per player.
@immutable
class MatchSide {
  const new({required this.players})
    : assert(players.length > 0, 'A side must have at least one player.');

  /// Players belonging to this side. Length is 1 or 2.
  final List<Player> players;

  /// Display name for the side. Single name, or "A / B" for a team.
  String get displayName => players.map((p) => p.fullName).join(' / ');
}
