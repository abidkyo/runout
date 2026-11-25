import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// A billiard player, uniquely identified and used across matches.
@freezed
@JsonSerializable()
class Player with _$Player {
  const new({
    required this.id,
    required this.name,
    this.countryCode,
    this.clubName,
  });

  factory fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, Object?> toJson() => _$PlayerToJson(this);

  /// Stable unique identifier (used for persistence and sync).
  final String id;

  /// Player's name.
  final String name;

  /// ISO 3166-1 alpha-2 country code (e.g. "US", "DE", "PH").
  final String? countryCode;

  /// Name of the player's club.
  final String? clubName;
}
