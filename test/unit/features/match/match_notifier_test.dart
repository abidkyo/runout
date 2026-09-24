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
}
