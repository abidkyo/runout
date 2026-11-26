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

    _commit(
      _match.copyWith(
        status: MatchStatus.playing,
        startedAt: clock.now(),
        currentSideIndex: sideIndex,
        sides: sides,
      ),
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
    scoreVisit(points: 0);
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
    scoreVisit(
      points: points,
      ballsRemaining: remaining,
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
    scoreVisit(
      points: points,
      ballsRemaining: MatchDefaults.ballsPerRack,
      keepsTurn: true,
    );
  }

  /// Scores one rack for [sideIndex] and updates the breaking side.
  ///
  /// Only valid for 8-ball, 9-ball, and 10-ball. Each call awards one point.
  /// Reaching [MatchConfig.raceTo] finishes the match.
  void scoreRack(int sideIndex) {
    assert(
      _match.config.gameType != GameType.straightPool,
      'scoreRack is only for non-straight-pool games.',
    );
    if (_match.config.gameType == GameType.straightPool) return;

    if (!_canScore(sideIndex, 1, Foul.none)) return;

    final scoringSide = _match.sides[sideIndex];
    final sides = List<MatchSide>.of(_match.sides);

    final score = scoringSide.score + 1;
    sides[sideIndex] = scoringSide.copyWith(score: score);

    final nextSideIndex = _nextSide(sideIndex);
    final finished = score >= _match.config.raceTo;

    _commit(
      _match.copyWith(
        sides: sides,
        currentSideIndex: nextSideIndex,
        status: finished ? MatchStatus.finished : _match.status,
        endedAt: finished ? clock.now() : null,
        pausedAt: finished ? null : _match.pausedAt,
        winnerIndex: finished ? sideIndex : null,
      ),
    );
  }

  /// Scores a straight-pool visit for the current side.
  ///
  /// [points] is the score added by the visit. The next side's innings
  /// counter is incremented by one when the visit ends.
  ///
  /// [ballsRemaining] is the balls left on the table after the visit; omit it
  /// to leave the count unchanged.
  ///
  /// [keepsTurn] leaves the breaker unchanged and skips the innings
  /// increment. A third consecutive [Foul.standard] forces [keepsTurn]
  /// regardless of the passed value.
  ///
  /// If a winner is found — by reaching [MatchConfig.raceTo] or by the
  /// innings limit firing — the match is ended and [MatchStatus.finished]
  /// is set. The innings limit fires when any side has exceeded
  /// [MatchConfig.inningsLimit]; the side with the highest score then wins.
  void scoreVisit({
    required int points,
    int? ballsRemaining,
    bool keepsTurn = false,
    Foul foul = Foul.none,
  }) {
    assert(
      _match.config.gameType == GameType.straightPool,
      'scoreVisit is only for straight pool.',
    );
    if (_match.config.gameType != GameType.straightPool) return;
    if (_match.status != MatchStatus.playing) return;

    final sideIndex = _match.currentSideIndex;
    assert(sideIndex != null, 'A straight-pool visit needs a current side.');
    if (sideIndex == null) return;

    if (!_canScore(sideIndex, points, foul)) return;

    _resetNotifications();

    final scoringSide = _match.sides[sideIndex];
    final sides = List<MatchSide>.of(_match.sides);

    var score = scoringSide.score + points - foul.value;
    final reachedTarget = score >= _match.config.raceTo;

    // Foul counters. A third standard foul forces the turn to stay.
    var consecutiveFouls = scoringSide.consecutiveFouls;
    var isThirdFoul = false;
    if (foul == Foul.standard) {
      consecutiveFouls += 1;
      if (consecutiveFouls >= 3) {
        score -= MatchDefaults.threeFoulsPenalty;
        consecutiveFouls = 0;
        isThirdFoul = true;
      }
    } else {
      consecutiveFouls = 0;
    }

    final effectiveKeepsTurn = keepsTurn || isThirdFoul;

    final nextSideIndex = effectiveKeepsTurn
        ? _match.currentSideIndex!
        : _nextSide(sideIndex);

    // Accumulate the run and keep the high run live.
    var highRun = scoringSide.highRun;
    var currentRun = _match.currentRun + points;
    if (currentRun > highRun) highRun = currentRun;
    if (!effectiveKeepsTurn) currentRun = 0;

    sides[sideIndex] = scoringSide.copyWith(
      score: score,
      highRun: highRun,
      consecutiveFouls: consecutiveFouls,
    );

    var effectiveLimit = _match.effectiveInningsLimit;
    var nextBallsRemaining = ballsRemaining ?? _match.ballsRemaining;
    var isOpeningBreak = _match.isOpeningBreak;

    if (foul != Foul.breakFoul || !effectiveKeepsTurn) {
      isOpeningBreak = false;
    }

    if (isThirdFoul) {
      isOpeningBreak = true;
      nextBallsRemaining = MatchDefaults.ballsPerRack;
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
    } else if (!effectiveKeepsTurn) {
      final nextSide = sides[nextSideIndex];
      sides[nextSideIndex] = nextSide.copyWith(innings: nextSide.innings + 1);

      final reachedInningsLimit = sides.any(
        (side) => side.innings > effectiveLimit,
      );

      if (reachedInningsLimit) {
        final highestScore = sides.map((side) => side.score).reduce(max);

        final winners = <int>[];
        for (var i = 0; i < sides.length; i++) {
          if (sides[i].score == highestScore) winners.add(i);
        }

        if (winners.length == 1) {
          winnerIndex = winners.first;
        } else {
          effectiveLimit =
              _match.effectiveInningsLimit + MatchDefaults.inningsExtension;
          notifyExtension = true;
        }
      }
    }

    final finished = winnerIndex != null;

    _commit(
      _match.copyWith(
        sides: sides,
        currentSideIndex: nextSideIndex,
        effectiveInningsLimit: effectiveLimit,
        currentRun: currentRun,
        ballsRemaining: nextBallsRemaining,
        isOpeningBreak: isOpeningBreak,
        status: finished ? MatchStatus.finished : _match.status,
        endedAt: finished ? clock.now() : null,
        pausedAt: finished ? null : _match.pausedAt,
        winnerIndex: winnerIndex,
      ),
    );
  }

  bool _canScore(int sideIndex, int points, Foul foul) {
    if (_match.status != MatchStatus.playing) return false;

    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );
    if (sideIndex < 0 || sideIndex >= _match.sides.length) return false;

    assert(points >= 0, 'points must not be negative.');
    if (points < 0) return false;

    if (_match.config.gameType == GameType.straightPool) {
      assert(
        sideIndex == _match.currentSideIndex,
        'In straight pool, only the current side can score.',
      );
      if (sideIndex != _match.currentSideIndex) return false;

      if (foul == Foul.breakFoul) {
        assert(
          points == 0,
          'In straight pool, cannot score points upon break foul.',
        );
        if (points != 0) return false;
      }
    }

    return true;
  }

  /// Computes who breaks next based on [BreakFormat].
  int _nextSide(int scoringSideIndex) {
    switch (_match.config.breakFormat) {
      case BreakFormat.winnerBreak:
        return scoringSideIndex;
      case BreakFormat.alternateBreak:
        final current = _match.currentSideIndex!;
        return (current + 1) % _match.sides.length;
    }
  }

  void _resetNotifications() {
    notifyExtension = false;
    notifyThreeFouls = false;
    askToContinue = false;
  }

  void _commit(Match next) {
    _undoStack.add(_match);
    _redoStack.clear();

    _match = next;
    notifyListeners();
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

  /// Marks a playing match as paused at the current time.
  ///
  /// This is time bookkeeping only; it does not add an undo step.
  void pause() {
    if (_match.status != MatchStatus.playing || _match.pausedAt != null) return;

    _match = _match.copyWith(pausedAt: clock.now());
    notifyListeners();
  }

  /// Resumes a paused match, adding the pause duration to the total.
  ///
  /// This is time bookkeeping only; it does not add an undo step.
  void resume() {
    if (_match.status != MatchStatus.playing || _match.pausedAt == null) return;

    _match = _match.resumeAt(clock.now());
    notifyListeners();
  }
}
