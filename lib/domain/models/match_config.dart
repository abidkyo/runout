import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';

part 'match_config.freezed.dart';

/// Configuration for a single match, decided on the setup page.
///
/// - [matchMode] determines how many sides the match has and how players
///   are grouped into sides.
/// - [breakFormat] applies to all game types. Straight pool uses
///   [BreakFormat.alternateBreak] by convention.
/// - [raceTo] is the target score for every game type.
/// - [inningsLimit] applies to straight pool only; use [0] otherwise.
@freezed
class MatchConfig with _$MatchConfig {
  const new({
    required this.matchMode,
    required this.gameType,
    required this.raceTo,
    required this.breakFormat,
    this.inningsLimit = 0,
  }) : assert(
         gameType == GameType.straightPool
             ? (inningsLimit > 0 && breakFormat == BreakFormat.alternateBreak)
             : (inningsLimit == 0),
         'Straight pool requires a positive inningsLimit and alternate break; '
         '8-ball, 9-ball, and 10-ball must use inningsLimit 0.',
       );

  /// How many sides the match has and how players are grouped.
  final MatchMode matchMode;

  /// The billiard variant being played.
  final GameType gameType;

  /// Target score to win.
  final int raceTo;

  /// Determines which side breaks each rack.
  final BreakFormat breakFormat;

  /// Maximum number of innings. Straight pool only; [0] otherwise.
  final int inningsLimit;
}
