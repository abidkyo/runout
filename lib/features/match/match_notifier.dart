import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';

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

  /// Whether the goal was reached during a turn that continues. Read and
  /// reset by the UI after showing the continue dialog.
  bool askToContinue = false;

  /// The current match state.
  Match get match => _match;

  /// Whether an undo is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether a redo is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// The side currently breaking, or null before the first break.
  int? get currentSideIndex => _match.currentSideIndex;

  /// Picks the side that will break first and starts the match.
  ///
  /// Only valid while the match is in [MatchStatus.created].
  ///
  /// In straight pool, selecting the starting side counts as that side's
  /// first visit, so their innings counter is incremented here.
  void selectStartingSide(int sideIndex) {
    assert(
      _match.status == MatchStatus.created,
      'Starting side can only be selected before the match starts.',
    );
    if (_match.status != MatchStatus.created) return;

    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );
    if (sideIndex < 0 || sideIndex >= _match.sides.length) return;

    final sides = List<MatchSide>.of(_match.sides);
    if (_match.config.gameType == GameType.straightPool) {
      final side = sides[sideIndex];
      sides[sideIndex] = side.copyWith(innings: side.innings + 1);
    }

    _pushHistory();
    _match = _match.copyWith(
      status: MatchStatus.playing,
      startedAt: clock.now(),
      currentSideIndex: sideIndex,
      sides: sides,
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
    incrementScore(_match.currentSideIndex ?? 0, points: 0);
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
      remaining >= 2 && remaining <= _match.ballsRemaining,
      'remaining must be between 2 and the current balls remaining.',
    );
    if (remaining < 2 || remaining > _match.ballsRemaining) return;

    final points = _match.ballsRemaining - remaining;
    incrementScore(
      _match.currentSideIndex ?? 0,
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

    final points = _match.ballsRemaining - remaining;
    incrementScore(
      _match.currentSideIndex ?? 0,
      points: points,
      remaining: MatchDefaults.ballsPerRack,
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
  /// The next side's innings counter is incremented by exactly one
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
        sideIndex == _match.currentSideIndex,
        'In straight pool, only the current side can score.',
      );
      if (sideIndex != _match.currentSideIndex) return;

      if (foul == Foul.breakFoul) {
        assert(
          points == 0,
          'In straight pool, cannot score points upon break foul.',
        );
        if (points != 0) return;
      }
    }

    // reset
    notifyExtension = false;
    notifyThreeFouls = false;
    askToContinue = false;

    final scoringSide = _match.sides[sideIndex];
    final updatedSides = List<MatchSide>.of(_match.sides);

    var updatedScore = scoringSide.score + points - foul.value;

    // Foul counters. A third standard foul forces the turn to stay.
    var updatedConsecutiveFouls = scoringSide.consecutiveFouls;
    var isThirdFoul = false;
    if (_match.config.gameType == GameType.straightPool) {
      if (foul == Foul.standard) {
        updatedConsecutiveFouls += 1;
        if (updatedConsecutiveFouls >= 3) {
          updatedConsecutiveFouls = 0;
          updatedScore -= MatchDefaults.threeFoulsPenalty;
          isThirdFoul = true;
        }
      } else {
        updatedConsecutiveFouls = 0;
      }
    }

    final effectiveKeepsTurn = keepsTurn || isThirdFoul;

    final reachedTarget = updatedScore >= _match.config.raceTo;
    final nextSideIndex = effectiveKeepsTurn
        ? _match.currentSideIndex!
        : _nextSide(scoringSideIndex: sideIndex);

    var updatedEffectiveLimit = _match.effectiveInningsLimit;
    var updatedBallsRemaining = remaining ?? _match.ballsRemaining;
    var updatedIsOpeningBreak = _match.isOpeningBreak;

    // Straight pool: accumulate the run and keep highRuns live.
    var updatedHighRun = scoringSide.highRun;
    var updatedCurrentRun = _match.currentRun;
    if (_match.config.gameType == GameType.straightPool) {
      updatedCurrentRun += points;

      if (updatedCurrentRun > updatedHighRun) {
        updatedHighRun = updatedCurrentRun;
      }

      if (!effectiveKeepsTurn) {
        updatedCurrentRun = 0;
      }
    }

    updatedSides[sideIndex] = scoringSide.copyWith(
      score: updatedScore,
      highRun: updatedHighRun,
      consecutiveFouls: updatedConsecutiveFouls,
    );

    if ((_match.config.gameType == GameType.straightPool) &&
        (foul != Foul.breakFoul || !effectiveKeepsTurn)) {
      updatedIsOpeningBreak = false;
    }

    if (isThirdFoul) {
      updatedIsOpeningBreak = true;
      updatedBallsRemaining = MatchDefaults.ballsPerRack;
      notifyThreeFouls = true;
    }

    var winnerIndex = _match.winnerIndex;

    // Score win takes priority over the innings limit.
    if (reachedTarget) {
      if (effectiveKeepsTurn) {
        askToContinue = true;
      } else {
        winnerIndex = sideIndex;
      }
    } else if (_match.config.gameType == GameType.straightPool &&
        !effectiveKeepsTurn) {
      final nextSide = updatedSides[nextSideIndex];
      updatedSides[nextSideIndex] = nextSide.copyWith(
        innings: nextSide.innings + 1,
      );

      final reachedInningsLimit = updatedSides.any(
        (side) => side.innings > updatedEffectiveLimit,
      );

      if (reachedInningsLimit) {
        final highestScore = updatedSides.map((side) => side.score).reduce(max);

        final winners = <int>[];
        for (var i = 0; i < updatedSides.length; i++) {
          if (updatedSides[i].score == highestScore) winners.add(i);
        }

        if (winners.length == 1) {
          winnerIndex = winners.first;
        } else {
          updatedEffectiveLimit =
              _match.effectiveInningsLimit + MatchDefaults.inningsExtension;
          notifyExtension = true;
        }
      }
    }

    final finished = winnerIndex != null;

    _pushHistory();
    _match = _match.copyWith(
      sides: updatedSides,
      currentSideIndex: nextSideIndex,
      effectiveInningsLimit: updatedEffectiveLimit,
      currentRun: updatedCurrentRun,
      ballsRemaining: updatedBallsRemaining,
      isOpeningBreak: updatedIsOpeningBreak,
      status: finished ? MatchStatus.finished : _match.status,
      endedAt: finished ? clock.now() : null,
      winnerIndex: winnerIndex,
    );
    notifyListeners();
  }

  /// Computes who breaks next based on [BreakFormat].
  int _nextSide({required int scoringSideIndex}) {
    switch (_match.config.breakFormat) {
      case BreakFormat.winnerBreak:
        return scoringSideIndex;
      case BreakFormat.alternateBreak:
        final current = _match.currentSideIndex!;
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
