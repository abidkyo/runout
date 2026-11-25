import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/repositories/player_repository.dart';

void main() {
  late AppDatabase database;
  late PlayerRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PlayerRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('loads no players from an empty database', () async {
    await repository.load();

    expect(await repository.getAll(), isEmpty);
  });

  test('adds and reloads a player', () async {
    final player = await repository.add('  Joshua Filler  ');

    expect(player.name, 'Joshua Filler');
    expect(await repository.getAll(), [player]);

    final reloaded = PlayerRepository(database);
    await reloaded.load();

    expect(await reloaded.getAll(), [player]);
  });

  test('reuses an existing name case-insensitively', () async {
    final first = await repository.add('Joshua Filler');
    final second = await repository.add('  joshua filler ');

    expect(second.id, first.id);
    expect(await repository.getAll(), hasLength(1));
  });

  test('sorts players by name', () async {
    await repository.add('Zed');
    await repository.add('alice');
    await repository.add('Bob');

    expect(
      (await repository.getAll()).map((player) => player.name),
      ['alice', 'Bob', 'Zed'],
    );

    final reloaded = PlayerRepository(database);
    await reloaded.load();

    expect(
      (await reloaded.getAll()).map((player) => player.name),
      ['alice', 'Bob', 'Zed'],
    );
  });

  test('rejects a blank name', () async {
    expect(
      () => repository.add('   '),
      throwsA(isA<ArgumentError>()),
    );
    expect(await repository.getAll(), isEmpty);
  });

  test('deletes a player', () async {
    final player = await repository.add('Joshua Filler');

    await repository.delete(player.id);

    expect(await repository.getAll(), isEmpty);
  });

  test('skips malformed and unsupported rows', () async {
    final valid = await repository.add('Valid');
    await database
        .into(database.players)
        .insert(
          PlayersCompanion.insert(
            id: 'bad-json',
            name: 'Bad',
            playerJson: 'not json',
            createdAt: DateTime.utc(2026),
          ),
        );
    await database
        .into(database.players)
        .insert(
          PlayersCompanion.insert(
            id: 'bad-version',
            name: 'Unsupported',
            playerJson: jsonEncode(<String, Object?>{
              'version': 2,
              'player': {},
            }),
            createdAt: DateTime.utc(2026),
          ),
        );

    final reloaded = PlayerRepository(database);
    await reloaded.load();

    expect(await reloaded.getAll(), [valid]);
  });
}
