import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:runout/data/local/match_codec.dart';
import 'package:runout/domain/models/match.dart';

import '../../helpers/factories.dart';

void main() {
  test('round-trips a match', () {
    final match =
        makeMatch(
          sides: [makeSide('0', score: 3), makeSide('1', score: 1)],
        ).copyWith(
          status: MatchStatus.playing,
          startedAt: DateTime(2026, 5, 4, 12, 30),
          currentSideIndex: 0,
        );

    final decoded = MatchCodec.decode(MatchCodec.encode(match));

    expect(
      decoded,
      match.copyWith(
        startedAt: match.startedAt!.toUtc(),
      ),
    );
  });

  test('encodes a versioned payload', () {
    final decoded =
        jsonDecode(MatchCodec.encode(makeMatch())) as Map<String, dynamic>;

    expect(decoded['version'], 1);
    expect(decoded['match'], isA<Map<String, dynamic>>());
  });

  test('rejects an unsupported version', () {
    final source = jsonEncode({'version': 2, 'match': makeMatch().toJson()});

    expect(() => MatchCodec.decode(source), throwsFormatException);
  });

  test('rejects malformed JSON', () {
    expect(() => MatchCodec.decode('not json'), throwsFormatException);
  });

  test('rejects a non-object payload', () {
    expect(() => MatchCodec.decode('[]'), throwsFormatException);
  });

  test('rejects a missing match payload', () {
    expect(
      () => MatchCodec.decode(jsonEncode({'version': 1})),
      throwsFormatException,
    );
  });
}
