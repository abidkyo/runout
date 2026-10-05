import 'package:meta/meta.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';

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
@immutable
class Match {
  const new({
    required this.id,
    required this.config,
    required this.sides,
    required this.scores,
    required this.innings,
    required this.highRuns,
    required this.foulCounters,
    required this.status,
    this.remaining = 15,
    this.currentRun = 0,
    this.isOpeningBreak = true,
    this.effectiveInningsLimit = 0,
    this.startedAt,
    this.endedAt,
    this.currentBreakerIndex,
    this.winnerIndex,
  }) : assert(sides.length >= 2, 'A match needs at least two sides.'),
       assert(
         scores.length == sides.length,
         'Scores must have one entry per side.',
       ),
       assert(
         innings.length == sides.length,
         'Innings must have one entry per side.',
       ),
       assert(
         highRuns.length == sides.length,
         'High runs must have one entry per side.',
       ),
       assert(
         foulCounters.length == sides.length,
         'Foul counters must have one entry per side.',
       );

  /// Stable unique identifier.
  final String id;

  /// Rules and settings chosen on the setup page.
  final MatchConfig config;

  /// The sides in this match. Order defines their index (0, 1, ...).
  final List<MatchSide> sides;

  /// Score per side, indexed parallel to [sides].
  final List<int> scores;

  /// Innings per side, indexed parallel to [sides].
  final List<int> innings;

  /// Highest single-visit score per side, indexed parallel to [sides].
  final List<int> highRuns;

  /// Consecutive-foul count per side, indexed parallel to [sides].
  ///
  /// Straight pool only; stays all-zeros for 8/9/10-ball. Incremented on
  /// each foul, reset to zero on a clean visit or after the third foul.
  final List<int> foulCounters;

  /// Current lifecycle state.
  final MatchStatus status;

  /// Balls remaining on the table. Straight pool only; starts at 15.
  final int remaining;

  /// Points accumulated in the current visit. Reset to zero when the
  /// visit ends. Straight pool only.
  final int currentRun;

  /// Current innings limit. Starts at `config.inningsLimit` for straight
  /// pool and grows by 5 on each tied innings limit. Zero for other games.
  final int effectiveInningsLimit;

  /// Whether the next shot is an opening break. Starts true; cleared after
  /// the first visit ends; set again by the three-foul penalty (re-rack).
  final bool isOpeningBreak;

  /// When the match started. Null until [status] is [MatchStatus.playing].
  final DateTime? startedAt;

  /// When the match ended. Null until [status] is [MatchStatus.finished].
  final DateTime? endedAt;

  /// Index into [sides] of the side currently breaking.
  /// Null before the first break is chosen.
  final int? currentBreakerIndex;

  /// Index into [sides] of the winning side. Null until finished.
  final int? winnerIndex;

  /// Returns a copy with the given fields replaced.
  ///
  /// Passing nothing keeps the current value.
  Match copyWith({
    String? id,
    MatchConfig? config,
    List<MatchSide>? sides,
    List<int>? scores,
    List<int>? innings,
    List<int>? highRuns,
    List<int>? foulCounters,
    int? remaining,
    int? currentRun,
    int? effectiveInningsLimit,
    bool? isOpeningBreak,
    MatchStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? currentBreakerIndex,
    int? winnerIndex,
  }) {
    return Match(
      id: id ?? this.id,
      config: config ?? this.config,
      sides: sides ?? this.sides,
      scores: scores ?? this.scores,
      innings: innings ?? this.innings,
      highRuns: highRuns ?? this.highRuns,
      foulCounters: foulCounters ?? this.foulCounters,
      remaining: remaining ?? this.remaining,
      effectiveInningsLimit:
          effectiveInningsLimit ?? this.effectiveInningsLimit,
      currentRun: currentRun ?? this.currentRun,
      isOpeningBreak: isOpeningBreak ?? this.isOpeningBreak,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      currentBreakerIndex: currentBreakerIndex ?? this.currentBreakerIndex,
      winnerIndex: winnerIndex ?? this.winnerIndex,
    );
  }
}
