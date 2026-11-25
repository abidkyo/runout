import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/local/player_codec.dart';
import 'package:runout/domain/models/player.dart';
import 'package:uuid/uuid.dart';

/// Provides access to the list of known players.
class PlayerRepository {
  new(this._database);

  final AppDatabase _database;
  final List<Player> _players = [];

  /// Loads all players from the local database.
  ///
  /// Rows that cannot be decoded are skipped.
  Future<void> load() async {
    final rows = await _database.select(_database.players).get();
    final players = <Player>[];

    for (final row in rows) {
      try {
        players.add(PlayerCodec.decode(row.playerJson));
      } on Object catch (error) {
        debugPrint('Skipping player ${row.id}: $error');
      }
    }

    _players
      ..clear()
      ..addAll(players);
  }

  /// Returns all known players, sorted by name.
  Future<List<Player>> getAll() async {
    final sorted = List<Player>.of(_players)
      ..sort((a, b) {
        final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return byName != 0 ? byName : a.id.compareTo(b.id);
      });

    return List.unmodifiable(sorted);
  }

  /// Adds a player, or returns the existing one with the same name.
  ///
  /// Matching is case-insensitive after trimming.
  /// Throws an [ArgumentError] for a blank name.
  Future<Player> add(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Player name must not be empty');
    }

    for (final player in _players) {
      if (player.name.toLowerCase() == trimmed.toLowerCase()) {
        return player;
      }
    }

    final newPlayer = Player(id: const Uuid().v7(), name: trimmed);

    await _database
        .into(_database.players)
        .insert(
          PlayersCompanion.insert(
            id: newPlayer.id,
            name: newPlayer.name,
            playerJson: PlayerCodec.encode(newPlayer),
            createdAt: clock.now().toUtc(),
          ),
        );

    _players.add(newPlayer);

    return newPlayer;
  }

  /// Removes the player with [id], if present.
  Future<void> delete(String id) async {
    await (_database.delete(_database.players)..where((table) {
          return table.id.equals(id);
        }))
        .go();

    _players.removeWhere((player) => player.id == id);
  }
}
