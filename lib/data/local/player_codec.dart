import 'dart:convert';

import 'package:runout/domain/models/player.dart';

/// Encodes and decodes versioned player snapshots.
abstract final class PlayerCodec {
  static const int _version = 1;

  /// Encodes [player] to a versioned JSON string.
  static String encode(Player player) => jsonEncode(<String, Object?>{
    'version': _version,
    'player': player.toJson(),
  });

  /// Decodes a versioned player snapshot.
  ///
  /// Throws a [FormatException] when the payload is malformed or has an
  /// unsupported version.
  static Player decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Player snapshot must be an object.');
    }
    final json = Map<String, Object?>.from(decoded);
    if (json['version'] != _version) {
      throw FormatException('Unsupported player snapshot: ${json['version']}');
    }
    final player = json['player'];
    if (player is! Map) {
      throw const FormatException('Player snapshot is missing.');
    }
    return Player.fromJson(Map<String, dynamic>.from(player));
  }
}
