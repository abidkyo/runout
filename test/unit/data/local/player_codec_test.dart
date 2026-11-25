import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:runout/data/local/player_codec.dart';
import 'package:runout/domain/models/player.dart';

void main() {
  const player = Player(
    id: 'p1',
    name: 'Joshua Filler',
    countryCode: 'DE',
    clubName: 'Germany',
  );

  test('round-trips a player', () {
    expect(PlayerCodec.decode(PlayerCodec.encode(player)), player);
  });

  test('encodes a versioned payload', () {
    final decoded =
        jsonDecode(PlayerCodec.encode(player)) as Map<String, dynamic>;

    expect(decoded['version'], 1);
    expect(decoded['player'], isA<Map<String, dynamic>>());
  });

  test('rejects an unsupported version', () {
    final source = jsonEncode({'version': 2, 'player': player.toJson()});

    expect(() => PlayerCodec.decode(source), throwsFormatException);
  });

  test('rejects malformed JSON', () {
    expect(() => PlayerCodec.decode('not json'), throwsFormatException);
  });

  test('rejects a non-object payload', () {
    expect(() => PlayerCodec.decode('[]'), throwsFormatException);
  });

  test('rejects a missing player payload', () {
    expect(
      () => PlayerCodec.decode(jsonEncode({'version': 1})),
      throwsFormatException,
    );
  });
}
