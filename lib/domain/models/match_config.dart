import 'package:meta/meta.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';

/// Configuration for a single match, decided on the setup page.
///
/// - [breakFormat] applies to all game types. Straight pool uses
///   [BreakFormat.alternateBreak] by convention.
/// - [raceTo] is the target score for every game type.
/// - [innings] applies to straight pool only.
@immutable
class MatchConfig {
  const new({
    required this.gameType,
    required this.raceTo,
    required this.breakFormat,
    this.innings,
  }) : assert(
         gameType == GameType.straightPool
             ? (innings != null && breakFormat == BreakFormat.alternateBreak)
             : (innings == null),
         'Straight pool requires innings and alternate break; '
         '8-ball, 9-ball, and 10-ball must not set innings.',
       );

  /// The billiard variant being played.
  final GameType gameType;

  /// Target score to win.
  final int raceTo;

  /// Determines which side breaks each rack.
  final BreakFormat breakFormat;

  /// Number of innings. Only for straight pool.
  final int? innings;
}
