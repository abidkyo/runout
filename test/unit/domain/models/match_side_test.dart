import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';

void main() {
  group('displayName', () {
    test('returns the player name for singles', () {
      final side = MatchSide(
        players: const [Player(id: 'p1', name: 'Alice')],
      );

      expect(side.displayName, 'Alice');
    });

    test('joins both players for doubles', () {
      final side = MatchSide(
        players: const [
          Player(id: 'p1', name: 'Alice'),
          Player(id: 'p2', name: 'Bob'),
        ],
      );

      expect(side.displayName, 'Alice & Bob');
    });
  });
}
