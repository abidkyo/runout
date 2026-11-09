import 'package:clock/clock.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';

/// Provides access to known matches.
///
/// Currently backed by an in-memory sample list. Will be backed by a local
/// database later.
class MatchRepository {
  /// Creates a repository, optionally seeded with [matches].
  ///
  /// The seed exists for tests; production uses the sample matches.
  new({List<Match>? matches})
    : _matches = List<Match>.of(matches ?? _sampleMatches());

  final List<Match> _matches;

  /// Returns all known matches in insertion order.
  List<Match> getAll() => List.unmodifiable(_matches);

  /// Returns playing matches, most recently started first.
  List<Match> getPlaying() {
    final matches =
        _matches.where((match) => match.status == MatchStatus.playing).toList()
          ..sort((a, b) => _activity(b).compareTo(_activity(a)));

    return List.unmodifiable(matches);
  }

  /// Returns finished matches, most recently ended first.
  ///
  /// When [limit] is provided, returns at most that many matches. The limit
  /// must not be negative.
  List<Match> getFinished({int? limit}) {
    assert(limit == null || limit >= 0, 'limit must not be negative.');
    if (limit != null && limit < 0) return const <Match>[];

    final matches =
        _matches.where((match) => match.status == MatchStatus.finished).toList()
          ..sort((a, b) => _activity(b).compareTo(_activity(a)));

    final result = limit == null ? matches : matches.take(limit);
    return List.unmodifiable(result);
  }

  /// Removes [match] and returns its index, or `-1` when it is absent.
  int delete(Match match) {
    final index = _matches.indexOf(match);
    if (index == -1) return -1;

    _matches.removeAt(index);
    return index;
  }

  /// Inserts [match] at [index], ignoring invalid indexes.
  void restore(int index, Match match) {
    if (index < 0 || index > _matches.length) return;
    _matches.insert(index, match);
  }

  static DateTime _activity(Match match) =>
      match.endedAt ??
      match.startedAt ??
      DateTime.fromMillisecondsSinceEpoch(0);

  static List<Match> _sampleMatches() {
    final now = clock.now();

    const fsr = Player(
      id: 'p-fsr',
      firstName: 'Francisco',
      lastName: 'Sanchez Ruiz',
    );
    const svb = Player(
      id: 'p-svb',
      firstName: 'Shane',
      lastName: 'Van Boening',
    );
    const chris = Player(
      id: 'p-chris',
      firstName: 'Chris',
      lastName: 'Anderson',
    );
    const michael = Player(
      id: 'p-michael',
      firstName: 'Michael',
      lastName: 'Brown',
    );
    const davidWilson = Player(
      id: 'p-david-wilson',
      firstName: 'David',
      lastName: 'Wilson',
    );
    const john = Player(id: 'p-john', firstName: 'John', lastName: 'Smith');
    const efren = Player(
      id: 'p-efren',
      firstName: 'Efren',
      lastName: 'Reyes',
    );
    const ronnie = Player(
      id: 'p-ronnie',
      firstName: 'Ronnie',
      lastName: "O'Sullivan",
    );
    const jasmin = Player(
      id: 'p-jasmin',
      firstName: 'Jasmin',
      lastName: 'Ouschan',
    );

    const straightPoolSingles = MatchConfig(
      matchMode: MatchMode.singles,
      gameType: GameType.straightPool,
      raceTo: 75,
      inningsLimit: 25,
      breakFormat: BreakFormat.alternateBreak,
    );
    const nineBallThreePlayers = MatchConfig(
      matchMode: MatchMode.threePlayer,
      gameType: GameType.nineBall,
      raceTo: 5,
      breakFormat: BreakFormat.winnerBreak,
    );
    const tenBallDoubles = MatchConfig(
      matchMode: MatchMode.doubles,
      gameType: GameType.tenBall,
      raceTo: 5,
      breakFormat: BreakFormat.winnerBreak,
    );

    final playingSingles =
        Match.create(
          id: 'match-1',
          config: straightPoolSingles,
          sides: [
            MatchSide(players: const [fsr]),
            MatchSide(players: const [svb]),
          ],
        ).copyWith(
          status: MatchStatus.playing,
          scores: const [30, 5],
          startedAt: now.subtract(const Duration(hours: 2)),
          currentBreakerIndex: 0,
        );

    final playingDoubles =
        Match.create(
          id: 'match-2',
          config: tenBallDoubles,
          sides: [
            MatchSide(players: const [chris, michael]),
            MatchSide(players: const [davidWilson, john]),
          ],
        ).copyWith(
          status: MatchStatus.playing,
          scores: const [3, 2],
          startedAt: now.subtract(const Duration(days: 1, hours: 2)),
          currentBreakerIndex: 1,
        );

    final playingThreePlayers =
        Match.create(
          id: 'match-3',
          config: nineBallThreePlayers,
          sides: [
            MatchSide(players: const [efren]),
            MatchSide(players: const [ronnie]),
            MatchSide(players: const [jasmin]),
          ],
        ).copyWith(
          status: MatchStatus.playing,
          scores: const [3, 2, 1],
          startedAt: now.subtract(const Duration(hours: 5)),
          currentBreakerIndex: 0,
        );

    final finishedSingles =
        Match.create(
          id: 'match-4',
          config: straightPoolSingles,
          sides: [
            MatchSide(players: const [fsr]),
            MatchSide(players: const [svb]),
          ],
        ).copyWith(
          status: MatchStatus.finished,
          scores: const [75, 25],
          startedAt: now.subtract(const Duration(days: 3, hours: 2)),
          endedAt: now.subtract(const Duration(days: 3)),
          currentBreakerIndex: 1,
          winnerIndex: 0,
        );

    final finishedDoubles =
        Match.create(
          id: 'match-5',
          config: tenBallDoubles,
          sides: [
            MatchSide(players: const [chris, michael]),
            MatchSide(players: const [davidWilson, john]),
          ],
        ).copyWith(
          status: MatchStatus.finished,
          scores: const [5, 8],
          startedAt: now.subtract(const Duration(days: 10, hours: 2)),
          endedAt: now.subtract(const Duration(days: 10)),
          currentBreakerIndex: 0,
          winnerIndex: 1,
        );

    final finishedThreePlayers =
        Match.create(
          id: 'match-6',
          config: nineBallThreePlayers,
          sides: [
            MatchSide(players: const [efren]),
            MatchSide(players: const [ronnie]),
            MatchSide(players: const [jasmin]),
          ],
        ).copyWith(
          status: MatchStatus.finished,
          scores: const [10, 12, 11],
          startedAt: now.subtract(const Duration(days: 15, hours: 2)),
          endedAt: now.subtract(const Duration(days: 15)),
          currentBreakerIndex: 0,
          winnerIndex: 1,
        );

    return [
      playingSingles,
      playingDoubles,
      playingThreePlayers,
      finishedSingles,
      finishedDoubles,
      finishedThreePlayers,
    ];
  }
}
