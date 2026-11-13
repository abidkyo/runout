import 'package:runout/domain/models/player.dart';

/// Provides access to the list of known players.
///
/// Currently backed by an in-memory sample list of professional players.
/// Will be backed by a local database later.
class PlayerRepository {
  /// Returns all known players.
  List<Player> getAll() => const [
    Player(
      id: 'p1',
      name: 'Joshua Filler',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    Player(
      id: 'p2',
      name: 'Ralf Souquet',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    Player(
      id: 'p3',
      name: 'Shane Van Boening',
      countryCode: 'US',
      clubName: 'United States',
    ),
    Player(
      id: 'p4',
      name: 'Skyler Woodward',
      countryCode: 'US',
      clubName: 'United States',
    ),
    Player(
      id: 'p5',
      name: 'Francisco Sanchez Ruiz',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    Player(
      id: 'p6',
      name: 'David Alcaide',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    Player(
      id: 'p7',
      name: 'Dennis Orcollo',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    Player(
      id: 'p8',
      name: 'Carlo Biado',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    Player(
      id: 'p9',
      name: 'Ko Pin-Yi',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
    Player(
      id: 'p10',
      name: 'Chang Jung-Lin',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
  ];
}
