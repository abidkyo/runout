import 'package:flutter_test/flutter_test.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';

import '../../helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

Match _playingMatch() {
  return makeMatch().copyWith(
    id: 'playing',
    status: MatchStatus.playing,
    startedAt: _base,
    currentBreakerIndex: 0,
  );
}

Match _finishedMatch(int index) {
  return makeMatch().copyWith(
    id: 'finished-$index',
    status: MatchStatus.finished,
    scores: const [10, 5],
    startedAt: _base.add(Duration(days: index)),
    endedAt: _base.add(Duration(days: index, hours: 1)),
    winnerIndex: 0,
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('sample data', () {
    test('contains playing, finished, and three-player matches', () {
      final repository = MatchRepository();

      expect(repository.getAll(), hasLength(6));
      expect(repository.getPlaying(), hasLength(3));
      expect(repository.getFinished(), hasLength(3));
      expect(
        repository.getPlaying().any((match) => match.sides.length == 3),
        isTrue,
      );
      expect(
        repository.getFinished().any((match) => match.sides.length == 3),
        isTrue,
      );
    });
  });

  group('queries', () {
    test('returns only playing matches', () {
      final repository = MatchRepository(
        matches: [makeMatch(), _playingMatch(), _finishedMatch(0)],
      );

      expect(repository.getPlaying().map((match) => match.id), ['playing']);
    });

    test('returns finished matches newest first', () {
      final repository = MatchRepository(
        matches: [
          _finishedMatch(0),
          _playingMatch(),
          _finishedMatch(2),
          _finishedMatch(1),
        ],
      );

      expect(
        repository.getFinished().map((match) => match.id),
        ['finished-2', 'finished-1', 'finished-0'],
      );
    });

    test('getFinished limits after sorting', () {
      final repository = MatchRepository();

      final limited = repository.getFinished(limit: 2);

      expect(limited.map((match) => match.id), ['match-4', 'match-5']);
    });

    test('getFinished with a zero limit is empty', () {
      final repository = MatchRepository();

      expect(repository.getFinished(limit: 0), isEmpty);
    });

    test('getFinished rejects a negative limit', () {
      final repository = MatchRepository();

      expect(
        () => repository.getFinished(limit: -1),
        throwsAssertionError,
      );
    });

    test('getAll is unmodifiable', () {
      final repository = MatchRepository(matches: [_playingMatch()]);

      expect(
        () => repository.getAll().add(makeMatch()),
        throwsUnsupportedError,
      );
    });
  });

  group('mutations', () {
    test('delete returns the removed index', () {
      final playing = _playingMatch();
      final finished = _finishedMatch(0);
      final repository = MatchRepository(matches: [playing, finished]);

      expect(repository.delete(playing), 0);
      expect(repository.getAll(), [finished]);
    });

    test('delete returns minus one when the match is absent', () {
      final repository = MatchRepository(matches: [_playingMatch()]);

      expect(repository.delete(_finishedMatch(9)), -1);
    });

    test('restore inserts at the given index', () {
      final playing = _playingMatch();
      final finished = _finishedMatch(0);
      final repository = MatchRepository(matches: [finished])
        ..restore(0, playing);

      expect(repository.getAll(), [playing, finished]);
    });

    test('restore ignores invalid indexes', () {
      final playing = _playingMatch();
      final repository = MatchRepository(matches: [playing])
        ..restore(-1, _finishedMatch(0))
        ..restore(2, _finishedMatch(1));

      expect(repository.getAll(), [playing]);
    });
  });
}
