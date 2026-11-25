import 'dart:convert';

import 'package:runout/domain/models/match.dart';

/// Encodes and decodes versioned match snapshots.
abstract final class MatchCodec {
  static const int _version = 1;

  /// Encodes [match] to a versioned JSON string.
  static String encode(Match match) => jsonEncode(<String, Object?>{
    'version': _version,
    'match': match.toJson(),
  });

  /// Decodes a versioned match snapshot.
  ///
  /// Throws a [FormatException] when the payload is malformed or has an
  /// unsupported version.
  static Match decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Match snapshot must be an object.');
    }
    final json = Map<String, Object?>.from(decoded);
    if (json['version'] != _version) {
      throw FormatException('Unsupported match snapshot: ${json['version']}');
    }
    final match = json['match'];
    if (match is! Map) {
      throw const FormatException('Match snapshot is missing.');
    }
    return Match.fromJson(Map<String, dynamic>.from(match));
  }
}
