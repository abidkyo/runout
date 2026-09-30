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
      firstName: 'Joshua',
      lastName: 'Filler',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    Player(
      id: 'p2',
      firstName: 'Ralf',
      lastName: 'Souquet',
      countryCode: 'DE',
      clubName: 'Germany',
    ),
    Player(
      id: 'p3',
      firstName: 'Shane',
      lastName: 'Van Boening',
      countryCode: 'US',
      clubName: 'United States',
    ),
    Player(
      id: 'p4',
      firstName: 'Skyler',
      lastName: 'Woodward',
      countryCode: 'US',
      clubName: 'United States',
    ),
    Player(
      id: 'p5',
      firstName: 'Francisco',
      lastName: 'Sanchez Ruiz',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    Player(
      id: 'p6',
      firstName: 'David',
      lastName: 'Alcaide',
      countryCode: 'ES',
      clubName: 'Spain',
    ),
    Player(
      id: 'p7',
      firstName: 'Dennis',
      lastName: 'Orcollo',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    Player(
      id: 'p8',
      firstName: 'Carlo',
      lastName: 'Biado',
      countryCode: 'PH',
      clubName: 'Philippines',
    ),
    Player(
      id: 'p9',
      firstName: 'Ko',
      lastName: 'Pin-Yi',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
    Player(
      id: 'p10',
      firstName: 'Chang',
      lastName: 'Jung-Lin',
      countryCode: 'TW',
      clubName: 'Chinese Taipei',
    ),
  ];
}
