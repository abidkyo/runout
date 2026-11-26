import 'package:flutter_test/flutter_test.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/foul.dart';
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
      expect(m.pausedAt, isNull);
      expect(m.totalPausedSeconds, 0);
      expect(m.currentSideIndex, isNull);
      expect(m.winnerIndex, isNull);
      expect(notifier.canUndo, isFalse);
      expect(notifier.canRedo, isFalse);
    });
  });

  group('selectStartingSide', () {
    test('starts the match and records breaker and start time', () {
      final notifier = MatchNotifier(makeMatch())..selectStartingSide(1);
      final m = notifier.match;

      expect(m.status, MatchStatus.playing);
      expect(m.startedAt, isNotNull);
      expect(m.currentSideIndex, 1);
    });

    test('enables undo after selection', () {
      final notifier = MatchNotifier(makeMatch())..selectStartingSide(0);
      expect(notifier.canUndo, isTrue);
    });

    test('throws when called after the match has started', () {
      final notifier = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(() => notifier.selectStartingSide(1), throwsAssertionError);
    });

    test('throws for an out-of-range side index', () {
      final notifier = MatchNotifier(makeMatch());

      expect(() => notifier.selectStartingSide(5), throwsAssertionError);
      expect(() => notifier.selectStartingSide(-1), throwsAssertionError);
    });
  });

  group('scoreRack', () {
    test('increments the given side only', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);

      expect(notifier.match.sides[0].score, 1);
      expect(notifier.match.sides[1].score, 0);
    });

    test('does nothing when match is not playing', () {
      final notifier = MatchNotifier(makeMatch())..scoreRack(0);
      expect(notifier.match.sides[0].score, 0);
      expect(notifier.match.status, MatchStatus.created);
    });

    test('throws for an out-of-range side index', () {
      final notifier = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(() => notifier.scoreRack(5), throwsAssertionError);
      expect(() => notifier.scoreRack(-1), throwsAssertionError);
    });

    test('is a no-op after the match has finished', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectStartingSide(0)
        ..scoreRack(0); // reaches raceTo, finishes match
      expect(notifier.match.status, MatchStatus.finished);

      final scoresBefore = List<int>.of(notifier.match.scores);
      notifier.scoreRack(1); // should be ignored

      expect(notifier.match.scores, scoresBefore);
      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
    });

    test('throws in straight pool', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(0);

      expect(() => n.scoreRack(0), throwsAssertionError);
    });
  });

  group('winner detection', () {
    test('finishes match when raceTo is reached', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 2)))
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..scoreRack(0);

      final m = notifier.match;
      expect(m.status, MatchStatus.finished);
      expect(m.winnerIndex, 0);
      expect(m.endedAt, isNotNull);
    });

    test('stays playing below raceTo', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 3)))
        ..selectStartingSide(0)
        ..scoreRack(0);

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
            ..selectStartingSide(0)
            ..scoreRack(0);
      expect(notifier.match.currentSideIndex, 0); // 0 wins, 0 breaks

      notifier.scoreRack(1); // side 1 scores while 0 was breaking
      expect(notifier.match.currentSideIndex, 1); // 1 wins, 1 breaks
    });

    test('alternateBreak: breaker switches and wraps around', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);
      expect(notifier.match.currentSideIndex, 1);

      // Switching from the last side wraps to the first.
      notifier.scoreRack(1);
      expect(notifier.match.currentSideIndex, 0);
    });

    test('alternateBreak: cycles through three sides', () {
      final notifier = MatchNotifier(makeMatch(sideCount: 3))
        ..selectStartingSide(0)
        ..scoreRack(0);
      expect(notifier.match.currentSideIndex, 1);

      notifier.scoreRack(1);
      expect(notifier.match.currentSideIndex, 2);

      notifier.scoreRack(2);
      expect(notifier.match.currentSideIndex, 0);
    });
  });

  group('undo', () {
    test('reverts the last action', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);
      expect(notifier.match.sides[0].score, 1);

      notifier.undo();
      expect(notifier.match.sides[0].score, 0);
      expect(notifier.match.status, MatchStatus.playing);
    });

    test('restores the previous breaker', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);
      expect(notifier.match.currentSideIndex, 1);

      notifier.undo();
      expect(notifier.match.currentSideIndex, 0);
    });

    test('steps back through multiple actions', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..undo()
        ..undo();

      expect(notifier.match.status, MatchStatus.created);
      expect(notifier.match.currentSideIndex, isNull);
    });

    test('is a no-op on empty stack', () {
      final notifier = MatchNotifier(makeMatch())..undo();
      expect(notifier.match.status, MatchStatus.created);
    });

    test('restores the winner state after finishing', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectStartingSide(0)
        ..scoreRack(0);
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
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..undo()
        ..redo();

      expect(notifier.match.sides[0].score, 1);
    });

    test('is a no-op on empty stack', () {
      final notifier = MatchNotifier(makeMatch())..redo();
      expect(notifier.match.status, MatchStatus.created);
    });

    test('is cleared by a new action', () {
      final notifier = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..undo();
      expect(notifier.canRedo, isTrue);

      notifier.scoreRack(1);
      expect(notifier.canRedo, isFalse);
    });

    test('reapplies the winner state after finishing', () {
      final notifier = MatchNotifier(makeMatch(config: makeConfig(raceTo: 1)))
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..undo()
        ..redo();

      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
      expect(notifier.match.endedAt, isNotNull);
    });
  });

  group('straight pool — selectStartingSide', () {
    test('increment inning (first visit) of the selected breaker', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(1);

      expect(n.match.innings, [0, 1]);
    });

    test('non-straight pool games leave innings untouched', () {
      final n = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(n.match.innings, [0, 0]);
    });
  });

  group('straight pool — scoring guard', () {
    test('throws when points are negative', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(0);

      expect(() => n.scoreVisit(points: -1), throwsAssertionError);
    });

    test('throws in rotation games', () {
      final n = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(() => n.scoreVisit(points: 1), throwsAssertionError);
    });
  });

  group('straight pool — increment innings', () {
    test('alternate increments of innings', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(1);

      expect(n.match.innings, [0, 1]);

      n.scoreVisit(points: 1);
      expect(n.match.innings, [1, 1]);

      n.scoreVisit(points: 1);
      expect(n.match.innings, [1, 2]);

      n.scoreVisit(points: 1);
      expect(n.match.innings, [2, 2]);
    });

    test('a zero-point visit still increment innings', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      n.scoreVisit(points: 0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 1]);
    });

    test('a multi-point visit increment innings by only one', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0);

      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      n.scoreVisit(points: 5);

      expect(n.match.scores, [5, 0]);
      expect(n.match.innings, [1, 1]);
    });

    test('non-straight pool games never increment innings', () {
      final n = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..scoreRack(0);

      expect(n.match.innings, [0, 0]);
    });
  });

  group('straight pool — highRuns and currentRun', () {
    test('start at zero', () {
      final n = MatchNotifier(makeStraightPoolMatch());

      expect(n.match.highRuns, [0, 0]);
      expect(n.match.currentRun, 0);
    });

    test('update highRuns live during a visit', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 5, ballsRemaining: 10, keepsTurn: true);

      expect(n.match.currentRun, 5);
      expect(n.match.highRuns, [5, 0]);
    });

    test('update highRuns live across multiple visits', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..scoreVisit(points: 4, ballsRemaining: 11, keepsTurn: true)
        ..scoreVisit(points: 6, ballsRemaining: 5, keepsTurn: true);

      expect(n.match.currentRun, 10);
      expect(n.match.highRuns, [10, 0]);
    });

    test('reset currentRun and update highRuns when the visit ends', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..scoreVisit(points: 5, ballsRemaining: 10, keepsTurn: true)
        ..scoreVisit(points: 3, ballsRemaining: 7); // visit ends

      expect(n.match.highRuns, [8, 0]);
      expect(n.match.currentRun, 0);
    });

    test('keeps the highest run across visits', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 10) // visit 1: high run 10
            ..scoreVisit(points: 3) // side 1 visit: high run 3
            ..scoreVisit(points: 5); // visit 2: high run stays 10

      expect(n.match.highRuns, [10, 3]);
    });

    test('keeps the highest run on mid-visit as well', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 10)
            ..scoreVisit(points: 3)
            ..scoreVisit(points: 5, keepsTurn: true);

      expect(n.match.currentRun, 5);
      expect(n.match.highRuns, [10, 3]);
    });

    test('a new higher run replaces the old one', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 5)
            ..scoreVisit(points: 2)
            ..scoreVisit(points: 9);

      expect(n.match.highRuns, [9, 2]);
    });

    test('non-straight-pool games never touch highRuns or currentRun', () {
      final n = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0)
        ..scoreRack(0);

      expect(n.match.highRuns, [0, 0]);
      expect(n.match.currentRun, 0);
    });

    test('the final visit still commits its run on a score win', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 20);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.highRuns, [20, 0]);
    });
  });

  group('straight pool — score win', () {
    test('reaching raceTo finishes the match and the scorer wins', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(1)
            ..scoreVisit(points: 20);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);
    });

    test('a multi-point visit can overshoot raceTo', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 14)
            ..scoreVisit(points: 2)
            ..scoreVisit(points: 14);

      expect(n.match.sides[0].score, 28);
      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });

    test('score win does not touch innings', () {
      final n =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 20))
            ..selectStartingSide(0)
            ..scoreVisit(points: 20);

      expect(n.match.innings, [1, 0]);
    });
  });

  group('straight pool — innings win', () {
    test('match ends when a side exceeds the innings limit', () {
      // limit 1, raceTo 10.
      // selectStartingSide(0): innings [1, 0]
      // scoreVisit(points: 1): innings [1, 1] — 1 > 1 is false, continue.
      // scoreVisit(points: 1): innings [2, 1] — 2 > 1 is true, finish.
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 3)
        ..scoreVisit(points: 2);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.endedAt, isNotNull);
      expect(n.match.innings, [2, 1]);
    });

    test('higher score wins, not the last scorer', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 4) // P1 = 4, innings [1, 1]
        ..scoreVisit(points: 2); // P2 = 2, innings [2, 1], finish

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });

    test('higher score wins, is the last scorer', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 1) // P1 = 1, innings [1, 1]
        ..scoreVisit(points: 4); // P2 = 4, innings [2, 1], finish

      expect(n.match.winnerIndex, 1);
    });

    test('match still playing while neither win condition has fired', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 1)
        ..scoreVisit(points: 1);

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
    });
  });

  group('straight pool — undo / redo', () {
    test('undo reverts the score, innings and remaining', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(12);

      expect(n.match.scores, [3, 0]);
      expect(n.match.innings, [1, 1]);
      expect(n.match.ballsRemaining, 12);

      n.undo();
      expect(n.match.scores, [0, 0]);
      expect(n.match.innings, [1, 0]);
      expect(n.match.ballsRemaining, 15);
    });

    test('undo after an innings win restores playing state', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 1)
        ..scoreVisit(points: 2);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);

      n.undo();

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
      expect(n.match.endedAt, isNull);
    });

    test('redo re-applies the innings win', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 1)
        ..scoreVisit(points: 2)
        ..undo()
        ..redo();

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 1);
      expect(n.match.endedAt, isNotNull);
    });

    test('undo after a score win restores playing state', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..scoreVisit(points: 20);

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
      expect(n.match.endedAt, isNotNull);

      n.undo();

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
      expect(n.match.endedAt, isNull);
    });

    test('redo re-applies the score win', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..scoreVisit(points: 20)
        ..undo()
        ..redo();

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
      expect(n.match.endedAt, isNotNull);
    });
  });

  group('straight pool — endVisit', () {
    test('ends the visit with no point', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..endVisit();

      expect(n.match.scores, [0, 0]);
    });

    test('advance breaker and increment inning', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(0);

      expect(n.match.innings, [1, 0]);
      expect(n.match.currentSideIndex, 0);
      n.endVisit();

      expect(n.match.innings, [1, 1]);
      expect(n.match.currentSideIndex, 1);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(n.endVisit, throwsAssertionError);
    });
  });

  group('straight pool — scoreRemaining', () {
    test('computes points from the remaining difference', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(10); // 15 - 10 = 5 points

      expect(n.match.scores, [5, 0]);
    });

    test('updates match.ballsRemaining', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(10);

      expect(n.match.ballsRemaining, 10);
    });

    test('advances breaker and counts innings', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(0);

      expect(n.match.currentSideIndex, 0);
      expect(n.match.innings, [1, 0]);

      n.scoreRemaining(10);
      expect(n.match.currentSideIndex, 1);
      expect(n.match.innings, [1, 1]);
    });

    test('a zero difference is valid and scores nothing', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(15); // 15 - 15 = 0

      expect(n.match.scores, [0, 0]);
      expect(n.match.ballsRemaining, 15);
      expect(n.match.currentSideIndex, 1);
    });

    test('throws when remaining is less than 2', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(10);

      expect(() => n.scoreRemaining(1), throwsAssertionError);
    });

    test('throws when remaining is more than current remaining', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreRemaining(10);

      expect(() => n.scoreRemaining(12), throwsAssertionError);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(() => n.scoreRemaining(10), throwsAssertionError);
    });
  });

  group('straight pool — newRack', () {
    test('scores the last ball, resets to 15, keeps the turn', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..newRack(1);

      expect(n.match.scores, [14, 0]);
      expect(n.match.ballsRemaining, 15);
      expect(n.match.currentSideIndex, 0);
    });

    test('table cleared scores all 15 and keeps the turn', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..newRack(0);

      expect(n.match.scores, [15, 0]);
      expect(n.match.ballsRemaining, 15);
      expect(n.match.currentSideIndex, 0);
    });

    test('does not increment innings', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0)
        ..newRack(1);

      expect(n.match.innings, [1, 0]);
    });

    test('throws when remaining is 2', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 20))
        ..selectStartingSide(0);

      expect(() => n.newRack(2), throwsAssertionError);
    });

    test('throws in non-straight-pool games', () {
      final n = MatchNotifier(makeMatch())..selectStartingSide(0);

      expect(() => n.newRack(1), throwsAssertionError);
    });
  });

  group('straight pool — innings extension', () {
    test('tied at the limit extends instead of finishing', () {
      final n = MatchNotifier(makeStraightPoolMatch());
      final current = n.match.effectiveInningsLimit;

      n
        ..selectStartingSide(0)
        ..scoreVisit(points: 2)
        ..scoreVisit(points: 2);

      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
      expect(
        n.match.effectiveInningsLimit,
        current + MatchDefaults.inningsExtension,
      );
    });

    test('sets notifyExtension when extending', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 2)
        ..scoreVisit(points: 2);

      expect(n.notifyExtension, isTrue);
    });

    test('notifyExtension is false when no extension fires', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..scoreVisit(points: 3)
        ..scoreVisit(points: 2);

      expect(n.notifyExtension, isFalse);
    });

    test('notifyExtension resets on the next increment', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 2)
        ..scoreVisit(points: 2);

      expect(n.notifyExtension, isTrue);

      n.scoreVisit(points: 1);

      expect(n.notifyExtension, isFalse);
    });

    test('a unique leader at the extended limit finishes the match', () {
      final n = MatchNotifier(makeStraightPoolMatch(raceTo: 100));
      final current = n.match.effectiveInningsLimit;

      n
        ..selectStartingSide(0)
        ..scoreVisit(points: 5)
        ..scoreVisit(points: 5);

      expect(
        n.match.effectiveInningsLimit,
        current + MatchDefaults.inningsExtension,
      );

      for (var i = 0; i < MatchDefaults.inningsExtension; i++) {
        n
          ..scoreVisit(points: i)
          ..endVisit();
      }

      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });
  });

  group('straight pool — fouls', () {
    test('standard foul deducts one point', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.scores, [-1, 0]);
    });

    test('standard foul increments the counter', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.consecutiveFouls, [1, 0]);
    });

    test('three standard fouls apply penalty and reset the counter', () {
      // Each standard foul: -1. Third also applies penalty.
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.sides[0].score, -3 - MatchDefaults.threeFoulsPenalty);
      expect(n.match.sides[0].consecutiveFouls, 0);
    });

    test('no foul resets the counter', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0);

      expect(n.match.sides[0].consecutiveFouls, 0);
    });

    test('break foul deducts two points', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul);

      expect(n.match.scores, [-2, 0]);
    });

    test('break foul resets the counter', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul);

      expect(n.match.sides[0].consecutiveFouls, 0);
    });

    test('break foul does not increment the counter', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul);

      expect(n.match.sides[0].consecutiveFouls, 0);
    });

    test('keepsTurn keeps the breaker after a break foul', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul, keepsTurn: true);

      expect(n.match.currentSideIndex, 0);
      expect(n.match.innings, [1, 0]);
    });

    test('sets notifyThreeFouls on the third standard foul', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.notifyThreeFouls, isTrue);
    });

    test('notifyThreeFouls is false when no penalty fires', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.notifyThreeFouls, isFalse);
    });

    test('non-straight-pool games never touch foul counters', () {
      final n = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);

      expect(n.match.consecutiveFouls, [0, 0]);
    });
  });

  group('straight pool — opening break flag', () {
    test('starts true on a fresh match', () {
      final n = MatchNotifier(makeStraightPoolMatch());

      expect(n.match.isOpeningBreak, isTrue);
    });

    test('stays true after selectStartingSide', () {
      final n = MatchNotifier(makeStraightPoolMatch())..selectStartingSide(0);

      expect(n.match.isOpeningBreak, isTrue);
    });

    test('becomes false after the first visit ends', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 3);

      expect(n.match.isOpeningBreak, isFalse);
    });

    test('clears after the first visit even with a foul', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.isOpeningBreak, isFalse);
    });

    test('stays true after breakfoul and keepsTurn is true', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul, keepsTurn: true);

      expect(n.match.isOpeningBreak, isTrue);
    });

    test('clears after breakfoul and keepsTurn is false', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.breakFoul);

      expect(n.match.isOpeningBreak, isFalse);
    });

    test('clears after scoring points with keepsTurn is true', () {
      final n = MatchNotifier(makeStraightPoolMatch())
        ..selectStartingSide(0)
        ..scoreVisit(points: 5, keepsTurn: true);

      expect(n.match.isOpeningBreak, isFalse);
    });

    test('three-foul penalty sets it back to true', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.isOpeningBreak, isTrue);
      expect(n.match.sides[0].consecutiveFouls, 0);
    });

    test('three-foul penalty resets remaining to 15', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.ballsRemaining, 15);
    });

    test('third standard foul forces keepsTurn', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard)
        ..scoreVisit(points: 0)
        ..scoreVisit(points: 0, foul: Foul.standard);

      expect(n.match.currentSideIndex, 0);
    });

    test('non-straight-pool games never touch isOpeningBreak', () {
      final n = MatchNotifier(makeMatch())
        ..selectStartingSide(0)
        ..scoreRack(0);

      expect(n.match.isOpeningBreak, isTrue);
    });
  });

  group('straight pool — continue after target', () {
    test('sets askToContinue when the target is reached on a kept turn', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 10, keepsTurn: true);

      expect(n.askToContinue, isTrue);
      expect(n.match.status, MatchStatus.playing);
      expect(n.match.winnerIndex, isNull);
    });

    test('does not set askToContinue when the target ends the visit', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 10);

      expect(n.askToContinue, isFalse);
      expect(n.match.status, MatchStatus.finished);
      expect(n.match.winnerIndex, 0);
    });

    test('askToContinue is set again when the target is still reached', () {
      final n = MatchNotifier(makeStraightPoolMatch(inningsLimit: 5, raceTo: 5))
        ..selectStartingSide(0)
        ..scoreVisit(points: 10, keepsTurn: true)
        ..askToContinue = false
        ..scoreVisit(points: 10, keepsTurn: true);

      expect(n.askToContinue, isTrue);
    });
  });
}

// ---------------------------------------------------------------------------

extension on Match {
  List<int> get scores => sides.map((s) => s.score).toList();
  List<int> get innings => sides.map((s) => s.innings).toList();
  List<int> get highRuns => sides.map((s) => s.highRun).toList();
  List<int> get consecutiveFouls =>
      sides.map((s) => s.consecutiveFouls).toList();
}
