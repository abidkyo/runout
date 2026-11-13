import 'package:meta/meta.dart';

/// A billiard player, uniquely identified and used across matches.
@immutable
class Player {
  const new({
    required this.id,
    required this.name,
    this.countryCode,
    this.clubName,
  });

  /// Stable unique identifier (used for persistence and sync).
  final String id;

  /// Player's name.
  final String name;

  /// ISO 3166-1 alpha-2 country code (e.g. "US", "DE", "PH").
  final String? countryCode;

  /// Name of the player's club.
  final String? clubName;
}
