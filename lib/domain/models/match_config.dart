import 'package:meta/meta.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';

/// Configuration for a single match, decided on the setup page.
///
/// - [breakFormat] applies to 8-ball, 9-ball, and 10-ball only.
/// - [raceTo] is the target score for every game type.
/// - [innings] applies to straight pool only.
@immutable
class MatchConfig {
  const new({
    required this.gameType,
    required this.raceTo,
    this.breakFormat,
    this.innings,
  }) : assert(
         gameType == GameType.straightPool
             ? innings != null
             : breakFormat != null,
         'Straight pool requires innings; '
         '8-ball, 9-ball, and 10-ball require breakFormat.',
       );

  /// The billiard variant being played.
  final GameType gameType;

  /// Target score to win.
  final int raceTo;

  /// Break rotation rule. Null for straight pool.
  final BreakFormat? breakFormat;

  /// Number of innings. Null for 8-ball, 9-ball, and 10-ball.
  final int? innings;
}
