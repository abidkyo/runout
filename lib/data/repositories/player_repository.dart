import 'package:runout/domain/models/player.dart';
import 'package:uuid/uuid.dart';

/// Provides access to the list of known players.
///
/// Currently backed by an in-memory sample list of professional players.
/// Will be backed by a local database later.
class PlayerRepository {
  new({List<Player>? players})
    : _players = List<Player>.of(players ?? _samplePlayers());

  final List<Player> _players;

  /// Returns all known players.
  Future<List<Player>> getAll() async => List.unmodifiable(_players);

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
    _players.insert(0, newPlayer);

    return newPlayer;
  }

  static List<Player> _samplePlayers() => [
    const Player(
      id: 'p1',
      name: 'Joshua Filler',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    const Player(
      id: 'p2',
      name: 'Ralf Souquet',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    const Player(
      id: 'p3',
      name: 'Shane Van Boening',
      countryCode: 'US',
      clubName: 'United States',
    ),
    const Player(
      id: 'p4',
      name: 'Skyler Woodward',
      countryCode: 'US',
      clubName: 'United States',
    ),
    const Player(
      id: 'p5',
      name: 'Francisco Sanchez Ruiz',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    const Player(
      id: 'p6',
      name: 'David Alcaide',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    const Player(
      id: 'p7',
      name: 'Dennis Orcollo',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    const Player(
      id: 'p8',
      name: 'Carlo Biado',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    const Player(
      id: 'p9',
      name: 'Ko Pin-Yi',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
    const Player(
      id: 'p10',
      name: 'Chang Jung-Lin',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
  ];
}
