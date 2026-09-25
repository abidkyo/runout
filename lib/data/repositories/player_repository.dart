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
    ),
    Player(
      id: 'p2',
      firstName: 'Fedor',
      lastName: 'Gorst',
      countryCode: 'RU',
    ),
    Player(
      id: 'p3',
      firstName: 'Shane',
      lastName: 'Van Boening',
      countryCode: 'US',
    ),
    Player(
      id: 'p4',
      firstName: 'Francisco',
      lastName: 'Sanchez Ruiz',
      countryCode: 'ES',
    ),
    Player(
      id: 'p5',
      firstName: 'Eklent',
      lastName: 'Kaci',
      countryCode: 'AL',
    ),
    Player(
      id: 'p6',
      firstName: 'Dennis',
      lastName: 'Orcollo',
      countryCode: 'PH',
    ),
    Player(
      id: 'p7',
      firstName: 'Jayson',
      lastName: 'Shaw',
      countryCode: 'GB',
    ),
    Player(
      id: 'p8',
      firstName: 'Albin',
      lastName: 'Ouschan',
      countryCode: 'AT',
    ),
    Player(
      id: 'p9',
      firstName: 'Niels',
      lastName: 'Feijen',
      countryCode: 'NL',
    ),
    Player(
      id: 'p10',
      firstName: 'Naoyuki',
      lastName: 'Oi',
      countryCode: 'JP',
    ),
  ];
}
