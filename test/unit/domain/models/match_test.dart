import 'package:flutter_test/flutter_test.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';

// ---------------------------------------------------------------------------

const _playerOne = Player(id: 'p1', name: 'Player 1');
const _playerTwo = Player(id: 'p2', name: 'Player 2');

MatchConfig _poolConfig() => const MatchConfig(
  matchMode: MatchMode.singles,
  gameType: GameType.eightBall,
  raceTo: 5,
  breakFormat: BreakFormat.winnerBreak,
);

MatchConfig _straightPoolConfig({int inningsLimit = 25}) => MatchConfig(
  matchMode: MatchMode.singles,
  gameType: GameType.straightPool,
  raceTo: 75,
  breakFormat: BreakFormat.alternateBreak,
  inningsLimit: inningsLimit,
);

List<MatchSide> _sides() => [
  MatchSide(players: [_playerOne]),
  MatchSide(players: [_playerTwo]),
];

void main() {
  group('MatchSide', () {
    test('requires at least one player', () {
      expect(
        () => MatchSide(players: []),
        throwsAssertionError,
      );
    });

    test('copyWith updates one stat and keeps the others', () {
      final side = _sides().first;
      final updated = side.copyWith(score: 5);

      expect(updated.score, 5);
      expect(updated.innings, 0);
      expect(updated.highRun, 0);
      expect(updated.consecutiveFouls, 0);
      expect(updated.players, side.players);
    });
  });

  group('MatchConfig', () {
    test('requires a positive innings limit for straight pool', () {
      expect(
        () => _straightPoolConfig(inningsLimit: 0),
        throwsAssertionError,
      );
    });

    test('requires alternate break for straight pool', () {
      expect(
        () => MatchConfig(
          matchMode: MatchMode.singles,
          gameType: GameType.straightPool,
          raceTo: 75,
          breakFormat: BreakFormat.winnerBreak,
          inningsLimit: 25,
        ),
        throwsAssertionError,
      );
    });

    test('rejects an innings limit for pool games', () {
      expect(
        () => MatchConfig(
          matchMode: MatchMode.singles,
          gameType: GameType.eightBall,
          raceTo: 5,
          breakFormat: BreakFormat.winnerBreak,
          inningsLimit: 25,
        ),
        throwsAssertionError,
      );
    });
  });

  group('Match.create', () {
    test('starts created with the opening break set', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      );

      expect(match.status, MatchStatus.created);
      expect(match.isOpeningBreak, isTrue);
      expect(match.currentSideIndex, isNull);
      expect(match.winnerIndex, isNull);
      expect(match.startedAt, isNull);
      expect(match.endedAt, isNull);
      expect(match.pausedAt, isNull);
      expect(match.totalPausedSeconds, 0);
    });

    test('seeds the effective innings limit for straight pool', () {
      final match = Match.create(
        id: 'match-1',
        config: _straightPoolConfig(inningsLimit: 50),
        sides: _sides(),
      );

      expect(match.effectiveInningsLimit, 50);
      expect(match.ballsRemaining, MatchDefaults.ballsPerRack);
    });

    test('uses zero for the effective innings limit in rotation games', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      );

      expect(match.effectiveInningsLimit, 0);
    });

    test('preserves pre-seeded side stats', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: [
          MatchSide(
            players: [_playerOne],
            score: 5,
            innings: 2,
            highRun: 3,
            consecutiveFouls: 1,
          ),
          MatchSide(players: [_playerTwo], score: 2),
        ],
      );

      expect(match.sides.first.score, 5);
      expect(match.sides.first.innings, 2);
      expect(match.sides.first.highRun, 3);
      expect(match.sides.first.consecutiveFouls, 1);
      expect(match.sides.last.score, 2);
    });
  });

  group('elapsedAt', () {
    final start = DateTime(2026, 5, 4, 12);

    Match playing({
      DateTime? endedAt,
      DateTime? pausedAt,
      int totalPausedSeconds = 0,
    }) {
      return Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      ).copyWith(
        status: MatchStatus.playing,
        startedAt: start,
        endedAt: endedAt,
        pausedAt: pausedAt,
        totalPausedSeconds: totalPausedSeconds,
      );
    }

    test('is zero before the match starts', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      );

      expect(match.elapsedAt(start), Duration.zero);
    });

    test('measures active time while playing', () {
      final match = playing();

      expect(
        match.elapsedAt(start.add(const Duration(minutes: 10))),
        const Duration(minutes: 10),
      );
    });

    test('subtracts completed pauses', () {
      final match = playing(totalPausedSeconds: 120);

      expect(
        match.elapsedAt(start.add(const Duration(minutes: 10))),
        const Duration(minutes: 8),
      );
    });

    test('subtracts the current pause', () {
      final match = playing(
        pausedAt: start.add(const Duration(minutes: 5)),
      );

      expect(
        match.elapsedAt(start.add(const Duration(minutes: 10))),
        const Duration(minutes: 5),
      );
    });

    test('subtracts completed and current pauses', () {
      final match = playing(
        pausedAt: start.add(const Duration(minutes: 5)),
        totalPausedSeconds: 60,
      );

      expect(
        match.elapsedAt(start.add(const Duration(minutes: 10))),
        const Duration(minutes: 4),
      );
    });

    test('uses endedAt for a finished match', () {
      final match = playing(
        endedAt: start.add(const Duration(minutes: 10)),
        totalPausedSeconds: 120,
      );

      expect(
        match.elapsedAt(start.add(const Duration(hours: 5))),
        const Duration(minutes: 8),
      );
    });

    test('never returns a negative duration', () {
      final match = playing(totalPausedSeconds: 600);

      expect(
        match.elapsedAt(start.add(const Duration(seconds: 1))),
        Duration.zero,
      );
    });

    test('ignores a current pause after the match finished', () {
      final match = playing(
        endedAt: start.add(const Duration(minutes: 10)),
        pausedAt: start.add(const Duration(minutes: 5)),
      );

      expect(
        match.elapsedAt(start.add(const Duration(minutes: 20))),
        const Duration(minutes: 10),
      );
    });
  });

  group('Match copyWith', () {
    test('returns an equal match with no arguments', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      );

      expect(match.copyWith(), match);
    });

    test('updates the current side without touching the sides', () {
      final match = Match.create(
        id: 'match-1',
        config: _poolConfig(),
        sides: _sides(),
      );

      final updated = match.copyWith(currentSideIndex: 1);

      expect(updated.currentSideIndex, 1);
      expect(updated.sides, match.sides);
    });
  });
}
