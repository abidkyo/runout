import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/local/match_codec.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';

import '../../helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

Match _playingMatch(
  String id, {
  DateTime? startedAt,
  int score = 0,
}) {
  return makeMatch(
    sides: [
      makeSide('0', score: score),
      makeSide('1'),
    ],
  ).copyWith(
    id: id,
    status: MatchStatus.playing,
    startedAt: startedAt ?? _base,
    currentSideIndex: 0,
  );
}

Match _finishedMatch(String id, DateTime endedAt) {
  return makeMatch(
    sides: [makeSide('0', score: 10), makeSide('1', score: 5)],
  ).copyWith(
    id: id,
    status: MatchStatus.finished,
    startedAt: endedAt.subtract(const Duration(hours: 1)),
    endedAt: endedAt,
    winnerIndex: 0,
  );
}

// ---------------------------------------------------------------------------

void main() {
  late AppDatabase database;
  late MatchRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = MatchRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('load', () {
    test('loads no matches from an empty database', () async {
      await repository.load();

      expect(repository.getPlaying(), isEmpty);
      expect(repository.getFinished(), isEmpty);
    });

    test('skips malformed and unsupported rows', () async {
      final valid = _playingMatch('valid');
      await repository.save(valid);
      await database
          .into(database.matches)
          .insert(
            MatchesCompanion.insert(
              id: 'bad-json',
              status: MatchStatus.playing.name,
              startedAt: _base,
              matchJson: 'not json',
              createdAt: DateTime.utc(2026),
            ),
          );
      await database
          .into(database.matches)
          .insert(
            MatchesCompanion.insert(
              id: 'bad-version',
              status: MatchStatus.playing.name,
              startedAt: _base,
              matchJson: jsonEncode(<String, Object?>{
                'version': 2,
                'match': {},
              }),
              createdAt: DateTime.utc(2026),
            ),
          );

      final reloaded = MatchRepository(database);
      await reloaded.load();

      expect(reloaded.getPlaying(), [valid]);
    });
  });

  group('save', () {
    test('does not store a created match', () async {
      await repository.save(makeMatch());

      final rows = await database.select(database.matches).get();

      expect(rows, isEmpty);
      expect(repository.getPlaying(), isEmpty);
    });

    test('requires a start time for a non-created match', () async {
      final match = makeMatch().copyWith(status: MatchStatus.playing);

      expect(() => repository.save(match), throwsStateError);
    });

    test('stores and reloads a playing match', () async {
      final match = _playingMatch('playing', score: 3);

      await repository.save(match);
      final reloaded = MatchRepository(database);
      await reloaded.load();

      expect(reloaded.getPlaying(), [match]);
      expect(reloaded.getFinished(), isEmpty);
    });

    test('stores and reloads a finished match', () async {
      final match = _finishedMatch(
        'finished',
        _base.add(const Duration(days: 1)),
      );

      await repository.save(match);
      final reloaded = MatchRepository(database);
      await reloaded.load();

      expect(reloaded.getFinished(), [match]);
      expect(reloaded.getPlaying(), isEmpty);
    });

    test('stores UTC JSON and matching column instants', () async {
      final match = _finishedMatch(
        'finished',
        _base.add(const Duration(days: 1)),
      );

      await repository.save(match);
      final row = await database.select(database.matches).getSingle();
      final decoded = MatchCodec.decode(row.matchJson);

      expect(decoded.startedAt!.isUtc, isTrue);
      expect(decoded.endedAt!.isUtc, isTrue);
      expect(row.startedAt.isAtSameMomentAs(match.startedAt!), isTrue);
      expect(row.endedAt!.isAtSameMomentAs(match.endedAt!), isTrue);
    });

    test('loads timestamps as local', () async {
      final match = _playingMatch('playing');

      await repository.save(match);
      final reloaded = MatchRepository(database);
      await reloaded.load();

      final loaded = reloaded.getPlaying().single;
      expect(loaded.startedAt!.isUtc, isFalse);
      expect(loaded.startedAt!.isAtSameMomentAs(match.startedAt!), isTrue);
    });

    test('updates an existing match and preserves createdAt', () async {
      final match = _playingMatch('playing');
      await repository.save(match);
      final first = await database.select(database.matches).getSingle();

      final updated = match.copyWith(
        sides: [makeSide('0', score: 7), makeSide('1')],
      );
      await repository.save(updated);
      final second = await database.select(database.matches).getSingle();

      expect(second.createdAt, first.createdAt);
      expect(repository.getPlaying().single.sides.first.score, 7);
    });
  });

  group('queries', () {
    test('returns playing matches newest first', () async {
      await repository.save(_playingMatch('old', startedAt: _base));
      await repository.save(
        _playingMatch('new', startedAt: _base.add(const Duration(days: 2))),
      );
      await repository.save(
        _playingMatch('middle', startedAt: _base.add(const Duration(days: 1))),
      );

      expect(
        repository.getPlaying().map((match) => match.id),
        ['new', 'middle', 'old'],
      );
    });

    test('returns finished matches newest first', () async {
      await repository.save(_finishedMatch('old', _base));
      await repository.save(
        _finishedMatch('new', _base.add(const Duration(days: 2))),
      );
      await repository.save(
        _finishedMatch('middle', _base.add(const Duration(days: 1))),
      );

      expect(
        repository.getFinished().map((match) => match.id),
        ['new', 'middle', 'old'],
      );
    });

    test('getFinished limits after sorting', () async {
      await repository.save(_finishedMatch('old', _base));
      await repository.save(
        _finishedMatch('new', _base.add(const Duration(days: 1))),
      );

      expect(
        repository.getFinished(limit: 1).map((match) => match.id),
        ['new'],
      );
    });

    test('getFinished with a zero limit is empty', () async {
      await repository.save(_finishedMatch('finished', _base));

      expect(repository.getFinished(limit: 0), isEmpty);
    });

    test('getFinished rejects a negative limit', () async {
      expect(
        () => repository.getFinished(limit: -1),
        throwsAssertionError,
      );
    });
  });

  group('delete', () {
    test('removes a match', () async {
      final match = _playingMatch('playing');
      await repository.save(match);

      await repository.delete(match.id);

      expect(repository.getPlaying(), isEmpty);
      final reloaded = MatchRepository(database);
      await reloaded.load();
      expect(reloaded.getPlaying(), isEmpty);
    });

    test('ignores an unknown id', () async {
      await repository.delete('missing');

      expect(repository.getPlaying(), isEmpty);
    });
  });
}
