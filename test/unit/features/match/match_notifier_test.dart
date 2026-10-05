import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';

import '../../helpers/factories.dart';

void main() {
  group('MatchNotifier initial state', () {
    test('starts in created status with no breaker, times, or winner', () {
      final notifier = MatchNotifier(makeMatch());
      final m = notifier.match;

      expect(m.status, MatchStatus.created);
      expect(m.startedAt, isNull);
      expect(m.endedAt, isNull);
      expect(m.currentBreakerIndex, isNull);
      expect(m.winnerIndex, isNull);
      expect(notifier.canUndo, isFalse);
      expect(notifier.canRedo, isFalse);
    });
  });

  group('selectBreaker', () {
    test('starts the match and records breaker and start time', () {
      final notifier = MatchNotifier(makeMatch())..selectBreaker(1);
      final m = notifier.match;

      expect(m.status, MatchStatus.playing);
      expect(m.startedAt, isNotNull);
      expect(m.currentBreakerIndex, 1);
    });

    test('enables undo after selection', () {
      final notifier = MatchNotifier(makeMatch())..selectBreaker(0);
      expect(notifier.canUndo, isTrue);
    });

    test('throws when called after the match has started', () {
      final notifier = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(() => notifier.selectBreaker(1), throwsAssertionError);
    });

    test('throws for an out-of-range side index', () {
      final notifier = MatchNotifier(makeMatch());

      expect(() => notifier.selectBreaker(5), throwsAssertionError);
      expect(() => notifier.selectBreaker(-1), throwsAssertionError);
    });
  });

  group('incrementScore', () {
    test('increments the given side only', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0);

      expect(notifier.match.scores[0], 1);
      expect(notifier.match.scores[1], 0);
    });

    test('does nothing when match is not playing', () {
      final notifier = MatchNotifier(makeMatch())..incrementScore(0);
      expect(notifier.match.scores[0], 0);
      expect(notifier.match.status, MatchStatus.created);
    });

    test('throws for an out-of-range side index', () {
      final notifier = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(() => notifier.incrementScore(5), throwsAssertionError);
      expect(() => notifier.incrementScore(-1), throwsAssertionError);
    });

    test('throws when points are negative', () {
      final n = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(() => n.incrementScore(0, points: -1), throwsAssertionError);
    });

    test('is a no-op after the match has finished', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectBreaker(0)
        ..incrementScore(0); // reaches raceTo, finishes match
      expect(notifier.match.status, MatchStatus.finished);

      final scoresBefore = List<int>.of(notifier.match.scores);
      notifier.incrementScore(1); // should be ignored

      expect(notifier.match.scores, scoresBefore);
      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
    });
  });

  group('winner detection', () {
    test('finishes match when raceTo is reached', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 2)))
        ..selectBreaker(0)
        ..incrementScore(0)
        ..incrementScore(0);

      final m = notifier.match;
      expect(m.status, MatchStatus.finished);
      expect(m.winnerIndex, 0);
      expect(m.endedAt, isNotNull);
    });

    test('stays playing below raceTo', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 3)))
        ..selectBreaker(0)
        ..incrementScore(0);

      expect(notifier.match.status, MatchStatus.playing);
      expect(notifier.match.winnerIndex, isNull);
    });
  });

  group('break format', () {
    test('winnerBreak: scoring side breaks next', () {
      final notifier =
          MatchNotifier(
              makeMatch(
                config: makeConfig(breakFormat: BreakFormat.winnerBreak),
              ),
            )
            ..selectBreaker(0)
            ..incrementScore(0);
      expect(notifier.match.currentBreakerIndex, 0); // 0 wins, 0 breaks

      notifier.incrementScore(1); // side 1 scores while 0 was breaking
      expect(notifier.match.currentBreakerIndex, 1); // 1 wins, 1 breaks
    });

    test('alternateBreak: breaker switches and wraps around', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0);
      expect(notifier.match.currentBreakerIndex, 1);

      // Switching from the last side wraps to the first.
      notifier.incrementScore(1);
      expect(notifier.match.currentBreakerIndex, 0);
    });

    test('alternateBreak: cycles through three sides', () {
      final notifier = MatchNotifier(makeMatch(sideCount: 3))
        ..selectBreaker(0)
        ..incrementScore(0);
      expect(notifier.match.currentBreakerIndex, 1);

      notifier.incrementScore(1);
      expect(notifier.match.currentBreakerIndex, 2);

      notifier.incrementScore(2);
      expect(notifier.match.currentBreakerIndex, 0);
    });
  });

  group('undo', () {
    test('reverts the last action', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0);
      expect(notifier.match.scores[0], 1);

      notifier.undo();
      expect(notifier.match.scores[0], 0);
      expect(notifier.match.status, MatchStatus.playing);
    });

    test('restores the previous breaker', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0);
      expect(notifier.match.currentBreakerIndex, 1);

      notifier.undo();
      expect(notifier.match.currentBreakerIndex, 0);
    });

    test('steps back through multiple actions', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0)
        ..undo()
        ..undo();

      expect(notifier.match.status, MatchStatus.created);
      expect(notifier.match.currentBreakerIndex, isNull);
    });

    test('is a no-op on empty stack', () {
      final notifier = MatchNotifier(makeMatch())..undo();
      expect(notifier.match.status, MatchStatus.created);
    });

    test('restores the winner state after finishing', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectBreaker(0)
        ..incrementScore(0);
      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
      expect(notifier.match.endedAt, isNotNull);

      notifier.undo();
      expect(notifier.match.status, MatchStatus.playing);
      expect(notifier.match.winnerIndex, isNull);
      expect(notifier.match.endedAt, isNull);
    });
  });

  group('redo', () {
    test('reapplies undone action', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0)
        ..undo()
        ..redo();

      expect(notifier.match.scores[0], 1);
    });

    test('is a no-op on empty stack', () {
      final notifier = MatchNotifier(makeMatch())..redo();
      expect(notifier.match.status, MatchStatus.created);
    });

    test('is cleared by a new action', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0)
        ..undo();
      expect(notifier.canRedo, isTrue);

      notifier.incrementScore(1);
      expect(notifier.canRedo, isFalse);
    });

    test('reapplies the winner state after finishing', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectBreaker(0)
        ..incrementScore(0)
        ..undo()
        ..redo();

      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
      expect(notifier.match.endedAt, isNotNull);
    });
  });

  group('straight pool — selectBreaker', () {
    test('increment inning (first visit) of the selected breaker', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 10),
      )..selectBreaker(1);

      expect(n.match.innings, [0, 1]);
    });

    test('non-straight pool games leave innings untouched', () {
      final n = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(n.match.innings, [0, 0]);
    });
  });

  group('straight pool — scoring guard', () {
    test('throws when a non-breaker tries to score', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 5, raceTo: 10),
      )..selectBreaker(0);

      expect(() => n.incrementScore(1), throwsAssertionError);
    });
  });

  group('straight pool — increment innings', () {
    test('alternate increments of innings', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 10),
      )..selectBreaker(1);

      expect(n.match.innings, [0, 1]);

      n.incrementScore(1);
      expect(n.match.innings, [1, 1]);

      n.incrementScore(0);
      expect(n.match.innings, [1, 2]);

      n.incrementScore(1);
      expect(n.match.innings, [2, 2]);
    });

    test('a zero-point visit still increment innings', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 10),
      )..selectBreaker(0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      n.incrementScore(0, points: 0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 1]);
    });

    test('a multi-point visit increment innings by only one', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 10),
      )..selectBreaker(0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      n.incrementScore(0, points: 5);

      expect(n.match.scores, [5, 0]);
      expect(n.match.innings, [1, 1]);
    });

    test('non-straight pool games never increment innings', () {
      final n = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0)
        ..incrementScore(1);

      expect(n.match.innings, [0, 0]);
    });
  });

  group('straight pool — highRuns and currentRun', () {
    test('start at zero', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 10),
      );

      expect(n.match.highRuns, [0, 0]);
      expect(n.match.currentRun, 0);
    });

    test('accumulate points during a visit', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..incrementScore(0, points: 5, remaining: 10, keepsTurn: true);

      expect(n.match.currentRun, 5);
      expect(n.match.highRuns, [0, 0]);
    });

    test('commit currentRun to highRuns when the visit ends', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..incrementScore(0, points: 5, remaining: 10, keepsTurn: true)
            ..incrementScore(0, points: 3, remaining: 7); // visit ends

      expect(n.match.highRuns, [8, 0]);
      expect(n.match.currentRun, 0);
    });

    test('keeps the highest run across visits', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..incrementScore(0, points: 10) // visit 1: high run 10
            ..incrementScore(1, points: 3) // side 1 visit: high run 3
            ..incrementScore(0, points: 5); // visit 2: high run stays 10

      expect(n.match.highRuns, [10, 3]);
    });

    test('a new higher run replaces the old one', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..incrementScore(0, points: 5)
            ..incrementScore(1, points: 2)
            ..incrementScore(0, points: 9);

      expect(n.match.highRuns, [9, 2]);
    });

    test('non-straight-pool games never touch highRuns or currentRun', () {
      final n = MatchNotifier(makeMatch())
        ..selectBreaker(0)
        ..incrementScore(0)
        ..incrementScore(1);

      expect(n.match.highRuns, [0, 0]);
      expect(n.match.currentRun, 0);
    });

    test('the final visit still commits its run on a score win', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 10);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.highRuns, [10, 0]);
    });
  });

  group('straight pool — score win', () {
    test('reaching raceTo finishes the match and the scorer wins', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(1)
            ..incrementScore(1, points: 10);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);
    });

    test('a multi-point visit can overshoot raceTo', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 7) // P1 = 7
            ..incrementScore(1, points: 2) // P2 = 2
            ..incrementScore(0, points: 6); // P1 = 13

      expect(n.match.scores[0], 13);
      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });

    test('score win does not touch innings', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 10);

      expect(n.match.innings, [1, 0]);
    });
  });

  group('straight pool — innings win', () {
    test('match ends when a side exceeds the innings limit', () {
      // limit 1, raceTo 10.
      // selectBreaker(0): innings [1, 0]
      // incrementScore(0): innings [1, 1] — 1 > 1 is false, continue.
      // incrementScore(1): innings [2, 1] — 2 > 1 is true, finish.
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0)
            ..incrementScore(1);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.endedAt, isNotNull);
      expect(n.match.innings, [2, 1]);
    });

    test('higher score wins, not the last scorer', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 4) // P1 = 4, innings [1, 1]
            ..incrementScore(1, points: 2); // P2 = 2, innings [2, 1], finish

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });

    test('higher score wins, is the last scorer', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0) // P1 = 1, innings [1, 1]
            ..incrementScore(1, points: 4); // P2 = 4, innings [2, 1], finish

      expect(n.match.winnerIndex, 1);
    });

    test('match still playing while neither win condition has fired', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0)
            ..incrementScore(1);

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
    });
  });

  group('straight pool — undo / redo', () {
    test('undo reverts the score, innings and remaining', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(12);

      expect(n.match.scores, [3, 0]);
      expect(n.match.innings, [1, 1]);
      expect(n.match.remaining, 12);

      n.undo();
      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      expect(n.match.remaining, 15);
    });

    test('undo after an innings win restores playing state', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0)
            ..incrementScore(1, points: 2);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);

      n.undo();

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
      expect(n.match.endedAt, isNull);
    });

    test('redo re-applies the innings win', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0)
            ..incrementScore(1, points: 2)
            ..undo()
            ..redo();

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);
    });

    test('undo after a score win restores playing state', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 10);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
      expect(n.match.endedAt, isNotNull);

      n.undo();

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
      expect(n.match.endedAt, isNull);
    });

    test('redo re-applies the score win', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 10))
            ..selectBreaker(0)
            ..incrementScore(0, points: 10)
            ..undo()
            ..redo();

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
      expect(n.match.endedAt, isNotNull);
    });
  });

  group('straight pool — endVisit', () {
    test('ends the visit with no point', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 10))
            ..selectBreaker(0)
            ..endVisit();

      expect(n.match.scores, [0, 0]);
    });

    test('advance breaker and increment inning', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 5, raceTo: 10),
      )..selectBreaker(0);

      expect(n.match.innings, [1, 0]);
      expect(n.match.currentBreakerIndex, 0);
      n.endVisit();

      expect(n.match.innings, [1, 1]);
      expect(n.match.currentBreakerIndex, 1);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(n.endVisit, throwsAssertionError);
    });
  });

  group('straight pool — scoreRemaining', () {
    test('computes points from the remaining difference', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(10); // 15 - 10 = 5 points

      expect(n.match.scores, [5, 0]);
    });

    test('updates match.remaining', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(10);

      expect(n.match.remaining, 10);
    });

    test('advances breaker and counts innings', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 1, raceTo: 10),
      )..selectBreaker(0);

      expect(n.match.currentBreakerIndex, 0);
      expect(n.match.innings, [1, 0]);

      n.scoreRemaining(10);
      expect(n.match.currentBreakerIndex, 1);
      expect(n.match.innings, [1, 1]);
    });

    test('a zero difference is valid and scores nothing', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(15); // 15 - 15 = 0

      expect(n.match.scores, [0, 0]);
      expect(n.match.remaining, 15);
      expect(n.match.currentBreakerIndex, 1);
    });

    test('throws when remaining is less than 2', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(10);

      expect(() => n.scoreRemaining(1), throwsAssertionError);
    });

    test('throws when remaining is more than current remaining', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(10);

      expect(() => n.scoreRemaining(12), throwsAssertionError);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(() => n.scoreRemaining(10), throwsAssertionError);
    });
  });

  group('straight pool — newRack', () {
    test('scores the last ball, resets to 15, keeps the turn', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..newRack(1);

      expect(n.match.scores, [14, 0]);
      expect(n.match.remaining, 15);
      expect(n.match.currentBreakerIndex, 0);
    });

    test('table cleared scores all 15 and keeps the turn', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..newRack(0);

      expect(n.match.scores, [15, 0]);
      expect(n.match.remaining, 15);
      expect(n.match.currentBreakerIndex, 0);
    });

    test('does not increment innings', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 2, raceTo: 20))
            ..selectBreaker(0)
            ..newRack(1);

      expect(n.match.innings, [1, 0]);
    });

    test('throws when remaining is 2', () {
      final n = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 2, raceTo: 20),
      )..selectBreaker(0);

      expect(() => n.newRack(2), throwsAssertionError);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectBreaker(0);

      expect(() => n.newRack(1), throwsAssertionError);
    });
  });
}
