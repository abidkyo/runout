import 'package:meta/meta.dart';

/// A billiard player, uniquely identified and used across matches.
@immutable
class Player {
  const new({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.countryCode,
    this.clubName,
  });

  /// Stable unique identifier (used for persistence and sync).
  final String id;

  /// Player's first name.
  final String firstName;

  /// Player's last name.
  final String lastName;

  /// ISO 3166-1 alpha-2 country code (e.g. "US", "DE", "PH").
  final String? countryCode;

  /// Name of the player's club.
  final String? clubName;

  /// Full name for display.
  String get fullName => '$firstName $lastName';
}
