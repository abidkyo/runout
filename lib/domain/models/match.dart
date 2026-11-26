import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';

part 'match.freezed.dart';
part 'match.g.dart';

/// The lifecycle state of a match.
enum MatchStatus {
  /// Created but not started. No break decided yet.
  created,

  /// Actively being played.
  playing,

  /// Finished — a winner has been decided.
  finished,
}

/// An actual played instance of a match.
///
/// Immutable. New states are produced by copying with updated values,
/// which is what makes undo/redo snapshots cheap and safe.
@freezed
@JsonSerializable()
class Match with _$Match {
  const new({
    required this.id,
    required this.config,
    required this.sides,
    required this.status,
    this.currentSideIndex,
    this.winnerIndex,
    this.effectiveInningsLimit = 0,
    this.currentRun = 0,
    this.ballsRemaining = MatchDefaults.ballsPerRack,
    this.isOpeningBreak = true,
    this.startedAt,
    this.endedAt,
    this.pausedAt,
    this.totalPausedSeconds = 0,
  }) : assert(
         sides.length >= 2,
         'A match needs at least two sides.',
       ),
       assert(
         totalPausedSeconds >= 0,
         'totalPausedSeconds must not be negative.',
       );

  /// Creates a new match from its [sides], preserving their stats.
  ///
  /// This is the convenience constructor for starting a fresh match: callers
  /// supply [id], [config], and [sides], and the lifecycle state starts at
  /// [MatchStatus.created].
  ///
  /// The [effectiveInningsLimit] is seeded from [MatchConfig.inningsLimit]
  /// for straight pool and remains zero for other games.
  factory create({
    required String id,
    required MatchConfig config,
    required List<MatchSide> sides,
  }) {
    final isStraightPool = config.gameType == GameType.straightPool;

    return Match(
      id: id,
      config: config,
      sides: sides,
      status: MatchStatus.created,
      effectiveInningsLimit: isStraightPool ? config.inningsLimit : 0,
    );
  }

  factory fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  Map<String, Object?> toJson() => _$MatchToJson(this);

  /// Stable unique identifier.
  final String id;

  /// Rules and settings chosen on the setup page.
  final MatchConfig config;

  /// The sides in this match. Order defines their index (0, 1, ...).
  final List<MatchSide> sides;

  /// Current lifecycle state.
  final MatchStatus status;

  /// Index into [sides] of the side currently breaking.
  /// Null before the first break is chosen.
  final int? currentSideIndex;

  /// Index into [sides] of the winning side. Null until finished.
  final int? winnerIndex;

  /// Current innings limit. Starts at `config.inningsLimit` for straight
  /// pool and grows by 5 on each tied innings limit. Zero for other games.
  final int effectiveInningsLimit;

  /// Points accumulated in the current visit. Reset to zero when the
  /// visit ends. Straight pool only.
  final int currentRun;

  /// Balls remaining on the table. Straight pool only; starts at
  /// [MatchDefaults.ballsPerRack].
  final int ballsRemaining;

  /// Whether the next shot is an opening break. Starts true. Cleared by a
  /// scoring call except a break foul that keeps the turn; set again by the
  /// three-foul re-rack.
  final bool isOpeningBreak;

  /// When the match started. Null before play starts.
  final DateTime? startedAt;

  /// When the match ended. Null until [status] is [MatchStatus.finished].
  final DateTime? endedAt;

  /// When the current pause started. Null when the match is not paused.
  final DateTime? pausedAt;

  /// Accumulated duration of completed pauses, in seconds.
  final int totalPausedSeconds;

  /// Returns this match with the current pause folded into the total.
  ///
  /// Returns the same match when it is not paused. Used when a stored match is
  /// reopened so its paused time is counted before play continues.
  Match resumeAt(DateTime now) {
    final pausedAt = this.pausedAt;
    if (pausedAt == null) return this;

    final paused = now.difference(pausedAt);
    final seconds = paused.isNegative ? 0 : paused.inSeconds;

    return copyWith(
      pausedAt: null,
      totalPausedSeconds: totalPausedSeconds + seconds,
    );
  }

  /// Actual play time at [now], excluding completed and current pauses.
  ///
  /// Returns zero before the match starts and never returns a negative value.
  Duration elapsedAt(DateTime now) {
    final start = startedAt;
    if (start == null) return Duration.zero;

    final end = endedAt ?? now;
    final pausedAt = this.pausedAt;

    var paused = Duration(seconds: totalPausedSeconds);

    if (endedAt == null && pausedAt != null) {
      final currentPause = now.difference(pausedAt);
      if (!currentPause.isNegative) paused += currentPause;
    }

    final elapsed = end.difference(start) - paused;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }
}
