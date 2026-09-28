import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/models/match.dart';

/// Holds the state of the current match and drives all transitions.
///
/// Undo/redo is implemented as two stacks of immutable [Match] snapshots.
class MatchNotifier extends ChangeNotifier {
  new(this._match);

  Match _match;
  final List<Match> _undoStack = [];
  final List<Match> _redoStack = [];

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
  void selectBreaker(int sideIndex) {
    assert(
      _match.status == MatchStatus.created,
      'Breaker can only be selected before the match starts.',
    );
    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );

    _pushHistory();
    _match = _match.copyWith(
      status: MatchStatus.playing,
      startedAt: clock.now(),
      currentBreakerIndex: sideIndex,
    );
    notifyListeners();
  }

  /// Increments the score of the given side by one.
  ///
  /// In 8-ball, 9-ball, and 10-ball, one point equals one rack won,
  /// so this also updates the breaking side based on [BreakFormat].
  /// Straight pool is not handled here yet.
  void incrementScore(int sideIndex) {
    if (_match.status != MatchStatus.playing) return;

    assert(
      sideIndex >= 0 && sideIndex < _match.sides.length,
      'sideIndex out of range.',
    );
    if (sideIndex < 0 || sideIndex >= _match.sides.length) return;

    final updatedScores = List<int>.of(_match.scores);
    updatedScores[sideIndex] += 1;

    final reachedTarget = updatedScores[sideIndex] >= _match.config.raceTo;
    final nextBreaker = _nextBreaker(scoringSide: sideIndex);

    if (reachedTarget) {
      _pushHistory();
      _match = _match.copyWith(
        scores: updatedScores,
        status: MatchStatus.finished,
        endedAt: clock.now(),
        winnerIndex: sideIndex,
        currentBreakerIndex: nextBreaker,
      );
      notifyListeners();
      return;
    }

    _pushHistory();
    _match = _match.copyWith(
      scores: updatedScores,
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
