import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';

/// Holds the state of the current match and drives all transitions.
///
/// Undo/redo is implemented as two stacks of immutable [Match] snapshots.
class MatchNotifier extends ChangeNotifier {
  new(this._match);

  Match _match;

  final List<Match> _undoStack = [];
  final List<Match> _redoStack = [];

  /// Whether the innings limit was extended during the last action.
  /// Read and reset by the UI after handling.
  bool notifyExtension = false;

  /// Whether the three-foul penalty fired during the last action.
  /// Read and reset by the UI after handling.
  bool notifyThreeFouls = false;

  /// The current match state.
  Match get match => _match;

  /// Whether an undo is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether a redo is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// The side currently breaking, or null before the first break.
  int? get currentBreakerIndex => _match.currentBreakerIndex;

  /// Picks the side that will break first and starts the match.
  ///
  /// Only valid while the match is in [MatchStatus.created].
  ///
  /// In straight pool, selecting the breaker counts as that side's first
  /// visit, so their innings counter is incremented here.
  void selectBreaker(int sideIndex) {
    assert(
      _match.status == MatchStatus.created,
      'Breaker can only be selected before the match starts.',
    );
    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );

    final innings = List<int>.of(_match.innings);
    if (_match.config.gameType == GameType.straightPool) {
      innings[sideIndex] += 1;
    }

    _pushHistory();
    _match = _match.copyWith(
      status: MatchStatus.playing,
      startedAt: clock.now(),
      currentBreakerIndex: sideIndex,
      innings: innings,
    );
    notifyListeners();
  }

  /// Ends the current inning without scoring, passing the break to the
  /// next side.
  /// Straight pool only.
  void endVisit() {
    assert(
      _match.config.gameType == GameType.straightPool,
      'endVisit is only for straight pool.',
    );
    if (_match.config.gameType != GameType.straightPool) return;
    incrementScore(_match.currentBreakerIndex ?? 0, points: 0);
  }

  /// Scores the balls potted since the last update, then ends the inning.
  ///
  /// [remaining] is the number of balls left on the table. Points are the
  /// difference from the previous value.
  /// Straight pool only.
  void scoreRemaining(
    int remaining, {
    bool keepsTurn = false,
    Foul foul = Foul.none,
  }) {
    assert(
      _match.config.gameType == GameType.straightPool,
      'scoreRemaining is only for straight pool.',
    );
    if (_match.config.gameType != GameType.straightPool) return;

    assert(
      remaining >= 2 && remaining <= _match.remaining,
      'remaining must be between 2 and the current remaining.',
    );
    if (remaining < 2 || remaining > _match.remaining) return;

    final points = _match.remaining - remaining;
    incrementScore(
      _match.currentBreakerIndex ?? 0,
      points: points,
      remaining: remaining,
      keepsTurn: keepsTurn,
      foul: foul,
    );
  }

  /// Ends a rack: scores the last ball(s), resets the table to 15, and
  /// keeps the turn.
  ///
  /// [remaining] is the balls left before re-racking: 0 or 1.
  /// Straight pool only.
  void newRack(int remaining) {
    assert(
      _match.config.gameType == GameType.straightPool,
      'newRack is only for straight pool.',
    );
    if (_match.config.gameType != GameType.straightPool) return;

    assert(
      remaining == 0 || remaining == 1,
      'remaining must be 0 or 1 when re-racking.',
    );
    if (remaining != 0 && remaining != 1) return;

    final points = _match.remaining - remaining;
    incrementScore(
      _match.currentBreakerIndex ?? 0,
      points: points,
      remaining: 15,
      keepsTurn: true,
    );
  }

  /// Increments the score of the given side by [points] and
  /// updates the breaking side based on [BreakFormat].
  ///
  /// In 8-ball, 9-ball, and 10-ball, one point equals one rack won;
  /// in straight pool, one point equals one ball.
  ///
  /// In straight pool, one call represents one visit to the table.
  /// The next breaker's innings counter is incremented by exactly one
  /// per call (their visit is counted before they play), regardless of
  /// [points].
  ///
  /// If a winner is found — by reaching [MatchConfig.raceTo] or by the
  /// innings limit firing — the match is ended and [MatchStatus.finished]
  /// is set. The innings limit fires when any side has exceeded
  /// [MatchConfig.inningsLimit]; the side with the highest score then wins.
  ///
  /// A [points] of zero is valid: it represents a visit that scored
  /// nothing but still passes the break to the other side.
  ///
  /// [remaining] is the balls left on the table after this visit; omit it
  /// to leave the count unchanged. Straight pool only.
  ///
  /// [keepsTurn] leaves the breaker unchanged and skips the innings
  /// increment. A third consecutive [Foul.standard] forces [keepsTurn]
  /// regardless of the passed value. Straight pool only.
  void incrementScore(
    int sideIndex, {
    int points = 1,
    int? remaining,
    bool keepsTurn = false,
    Foul foul = Foul.none,
  }) {
    if (_match.status != MatchStatus.playing) return;

    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );
    if (sideIndex < 0 || sideIndex >= _match.sides.length) return;

    assert(points >= 0, 'points must not be negative.');
    if (points < 0) return;

    if (_match.config.gameType == GameType.straightPool) {
      assert(
        sideIndex == _match.currentBreakerIndex,
        'In straight pool, only the current breaker can score.',
      );
      if (sideIndex != _match.currentBreakerIndex) return;
    }

    // reset
    notifyExtension = false;
    notifyThreeFouls = false;

    final updatedScores = List<int>.of(_match.scores);
    updatedScores[sideIndex] += points - foul.value;

    // Foul counters. A third standard foul forces the turn to stay.
    var updatedFoulCounters = _match.foulCounters;
    var isThirdFoul = false;
    if (_match.config.gameType == GameType.straightPool) {
      updatedFoulCounters = List<int>.of(_match.foulCounters);
      if (foul == Foul.standard) {
        updatedFoulCounters[sideIndex] += 1;
        if (updatedFoulCounters[sideIndex] >= 3) {
          updatedFoulCounters[sideIndex] = 0;
          updatedScores[sideIndex] -= 15;
          isThirdFoul = true;
        }
      } else {
        updatedFoulCounters[sideIndex] = 0;
      }
    }

    final effectiveKeepsTurn = keepsTurn || isThirdFoul;

    final reachedTarget = updatedScores[sideIndex] >= _match.config.raceTo;
    final nextBreaker = effectiveKeepsTurn
        ? _match.currentBreakerIndex!
        : _nextBreaker(scoringSide: sideIndex);

    var updatedInnings = _match.innings;
    var updatedEffectiveLimit = _match.effectiveInningsLimit;
    var updatedRemaining = remaining ?? _match.remaining;
    var updatedIsOpeningBreak = _match.isOpeningBreak;

    // Straight pool: accumulate the run; commit it when the visit ends.
    var updatedHighRuns = _match.highRuns;
    var updatedCurrentRun = _match.currentRun;
    if (_match.config.gameType == GameType.straightPool) {
      updatedCurrentRun += points;
      if (!effectiveKeepsTurn) {
        updatedHighRuns = List<int>.of(_match.highRuns);
        if (updatedCurrentRun > updatedHighRuns[sideIndex]) {
          updatedHighRuns[sideIndex] = updatedCurrentRun;
        }
        updatedCurrentRun = 0;
      }
    }

    if (_match.config.gameType == GameType.straightPool &&
        !effectiveKeepsTurn) {
      updatedIsOpeningBreak = false;
    }

    if (isThirdFoul) {
      updatedIsOpeningBreak = true;
      updatedRemaining = 15;
      notifyThreeFouls = true;
    }

    var winnerIndex = _match.winnerIndex;

    // Score win takes priority over the innings limit.
    if (reachedTarget) {
      winnerIndex = sideIndex;
    } else if (_match.config.gameType == GameType.straightPool &&
        !effectiveKeepsTurn) {
      updatedInnings = List<int>.of(_match.innings);
      updatedInnings[nextBreaker] += 1;

      final reachedInningsLimit = updatedInnings.any(
        (v) => v > updatedEffectiveLimit,
      );

      if (reachedInningsLimit) {
        final highestScore = updatedScores.reduce(max);

        final winners = <int>[];
        for (var i = 0; i < updatedScores.length; i++) {
          if (updatedScores[i] == highestScore) winners.add(i);
        }

        if (winners.length == 1) {
          winnerIndex = winners.first;
        } else {
          updatedEffectiveLimit = _match.effectiveInningsLimit + 5;
          notifyExtension = true;
        }
      }
    }

    final finished = winnerIndex != null;

    _pushHistory();
    _match = _match.copyWith(
      scores: updatedScores,
      innings: updatedInnings,
      highRuns: updatedHighRuns,
      foulCounters: updatedFoulCounters,
      remaining: updatedRemaining,
      currentRun: updatedCurrentRun,
      effectiveInningsLimit: updatedEffectiveLimit,
      isOpeningBreak: updatedIsOpeningBreak,
      status: finished ? MatchStatus.finished : null,
      endedAt: finished ? clock.now() : null,
      winnerIndex: winnerIndex,
      currentBreakerIndex: nextBreaker,
    );
    notifyListeners();
  }

  /// Computes who breaks next based on [BreakFormat].
  ///
  /// Returns the current breaker unchanged for straight pool, since
  /// break rotation is not defined there yet.
  int _nextBreaker({required int scoringSide}) {
    switch (_match.config.breakFormat) {
      case BreakFormat.winnerBreak:
        return scoringSide;
      case BreakFormat.alternateBreak:
        final current = _match.currentBreakerIndex!;
        return (current + 1) % _match.sides.length;
    }
  }

  /// Reverts the last action.
  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_match);
    _match = _undoStack.removeLast();
    notifyListeners();
  }

  /// Reapplies the last undone action.
  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_match);
    _match = _redoStack.removeLast();
    notifyListeners();
  }

  void _pushHistory() {
    _undoStack.add(_match);
    _redoStack.clear();
  }
}
