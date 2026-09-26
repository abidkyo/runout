import 'package:flutter_test/flutter_test.dart';
import 'package:runout/core/constants/match_limits.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';

import '../../helpers/factories.dart';

void main() {
  group('initial state', () {
    test('has default settings', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      expect(n.gameType, GameType.eightBall);
      expect(n.breakFormat, BreakFormat.winnerBreak);
      expect(n.raceTo, 5);
    });

    test('players grid matches mode shape (singles)', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      expect(n.players.length, 2);
      expect(n.players[0].length, 1);
      expect(n.players[1].length, 1);
      expect(n.players.expand((s) => s).every((p) => p == null), isTrue);
    });

    test('players grid matches mode shape (doubles)', () {
      final n = MatchSetupNotifier(mode: MatchMode.doubles);
      expect(n.players.length, 2);
      expect(n.players[0].length, 2);
      expect(n.players[1].length, 2);
    });

    test('players grid matches mode shape (threePlayer)', () {
      final n = MatchSetupNotifier(mode: MatchMode.threePlayer);
      expect(n.players.length, 3);
      expect(n.players[0].length, 1);
      expect(n.players[1].length, 1);
      expect(n.players[2].length, 1);
    });

    test('allPlayersPicked is false initially', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      expect(n.allPlayersPicked, isFalse);
    });
  });

  group('setters', () {
    test('gameType updates and notifies', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..gameType = GameType.nineBall;

      expect(n.gameType, GameType.nineBall);
      expect(notified, isTrue);
    });

    test('gameType with same value does not notify', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..gameType = GameType.eightBall;

      expect(notified, isFalse);
    });

    test('breakFormat updates and notifies', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..breakFormat = BreakFormat.alternateBreak;

      expect(n.breakFormat, BreakFormat.alternateBreak);
      expect(notified, isTrue);
    });

    test('raceTo clamps to minimum', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..raceTo = MatchLimits.minRaceTo - 1;
      expect(n.raceTo, MatchLimits.minRaceTo);
    });

    test('raceTo clamps to maximum', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..raceTo = MatchLimits.maxRaceTo + 1;
      expect(n.raceTo, MatchLimits.maxRaceTo);
    });

    test('raceTo with same value does not notify', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..raceTo = 5;

      expect(notified, isFalse);
    });
  });

  group('setPlayer', () {
    test('assigns the correct slot and notifies', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..setPlayer(1, 0, makePlayer('p1'));

      expect(n.players[1][0]?.id, 'p1');
      expect(notified, isTrue);
    });

    test('overwrites an existing player in the same slot', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'));
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..setPlayer(0, 0, makePlayer('p2'));

      expect(n.players[0][0]?.id, 'p2');
      expect(notified, isTrue);
    });

    test('ignores out-of-range side index without notifying', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..setPlayer(5, 0, makePlayer('p1'));

      expect(n.players.expand((s) => s).every((p) => p == null), isTrue);
      expect(notified, isFalse);
    });

    test('ignores out-of-range slot index without notifying', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles);
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..setPlayer(0, 5, makePlayer('p1'));

      expect(n.players.expand((s) => s).every((p) => p == null), isTrue);
      expect(notified, isFalse);
    });

    test('allPlayersPicked becomes true when all slots are filled', () {
      final n = MatchSetupNotifier(mode: MatchMode.doubles)
        ..setPlayer(0, 0, makePlayer('p1'))
        ..setPlayer(0, 1, makePlayer('p2'))
        ..setPlayer(1, 0, makePlayer('p3'));
      expect(n.allPlayersPicked, isFalse);

      n.setPlayer(1, 1, makePlayer('p4'));
      expect(n.allPlayersPicked, isTrue);
    });
  });

  group('clearPlayer', () {
    test('clears the specified slot and notifies', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'));
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..clearPlayer(0, 0);

      expect(n.players[0][0], isNull);
      expect(notified, isTrue);
    });

    test('allPlayersPicked becomes false after clearing', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'))
        ..setPlayer(1, 0, makePlayer('p2'));
      expect(n.allPlayersPicked, isTrue);

      n.clearPlayer(0, 0);

      expect(n.allPlayersPicked, isFalse);
    });

    test('ignores out-of-range indexes without notifying', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'));
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..clearPlayer(9, 9);

      expect(n.players[0][0]?.id, 'p1');
      expect(notified, isFalse);
    });

    test('ignores out-of-range slot with a valid side index', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'));
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..clearPlayer(0, 9);

      expect(n.players[0][0]?.id, 'p1');
      expect(notified, isFalse);
    });

    test('ignores out-of-range side with a valid slot index', () {
      final n = MatchSetupNotifier(mode: MatchMode.singles)
        ..setPlayer(0, 0, makePlayer('p1'));
      var notified = false;
      n
        ..addListener(() => notified = true)
        ..clearPlayer(9, 0);

      expect(n.players[0][0]?.id, 'p1');
      expect(notified, isFalse);
    });
  });
}
