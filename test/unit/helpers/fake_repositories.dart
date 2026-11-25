import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/domain/models/player.dart';

/// In-memory [MatchRepository] for widget and persistence tests.
class FakeMatchRepository implements MatchRepository {
  new({List<Match> matches = const []}) : _matches = List<Match>.of(matches);

  final List<Match> _matches;

  /// Matches passed to [save], in order.
  final List<Match> saves = [];

  /// Ids passed to [delete], in order.
  final List<String> deletes = [];

  /// Number of upcoming [save] calls that should fail.
  int failSaves = 0;

  /// Number of upcoming [delete] calls that should fail.
  int failDeletes = 0;

  List<Match> get matches => List.unmodifiable(_matches);

  @override
  Future<void> load() async {}

  @override
  List<Match> getPlaying() {
    final matches =
        _matches.where((match) => match.status == MatchStatus.playing).toList()
          ..sort((a, b) => _compareDescending(a.startedAt, b.startedAt));

    return List.unmodifiable(matches);
  }

  @override
  List<Match> getFinished({int? limit}) {
    assert(limit == null || limit >= 0, 'limit must not be negative.');
    if (limit != null && limit < 0) return const <Match>[];

    final matches =
        _matches.where((match) => match.status == MatchStatus.finished).toList()
          ..sort((a, b) => _compareDescending(a.endedAt, b.endedAt));

    final result = limit == null ? matches : matches.take(limit);
    return List.unmodifiable(result);
  }

  @override
  Future<void> save(Match match) async {
    if (failSaves > 0) {
      failSaves--;
      throw StateError('save failed');
    }

    saves.add(match);
    final index = _matches.indexWhere((candidate) => candidate.id == match.id);
    if (index == -1) {
      _matches.add(match);
    } else {
      _matches[index] = match;
    }
  }

  @override
  Future<void> delete(String id) async {
    if (failDeletes > 0) {
      failDeletes--;
      throw StateError('delete failed');
    }

    deletes.add(id);
    _matches.removeWhere((match) => match.id == id);
  }

  static int _compareDescending(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return b.compareTo(a);
  }
}

/// In-memory [PlayerRepository] for widget tests.
class FakePlayerRepository implements PlayerRepository {
  new({List<Player> players = const []}) : _players = List<Player>.of(players);

  final List<Player> _players;

  @override
  Future<void> load() async {}

  @override
  Future<List<Player>> getAll() async {
    final sorted = List<Player>.of(_players)
      ..sort((a, b) {
        final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return byName != 0 ? byName : a.id.compareTo(b.id);
      });

    return List.unmodifiable(sorted);
  }

  @override
  Future<Player> add(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Player name must not be empty');
    }

    for (final player in _players) {
      if (player.name.toLowerCase() == trimmed.toLowerCase()) {
        return player;
      }
    }

    final player = Player(id: 'fake-${_players.length}', name: trimmed);
    _players.add(player);

    return player;
  }

  @override
  Future<void> delete(String id) async {
    _players.removeWhere((player) => player.id == id);
  }
}

/// Convenience player list used by setup widget tests.
List<Player> fakePlayers() => const [
  Player(id: 'p1', name: 'Joshua Filler'),
  Player(id: 'p2', name: 'Shane Van Boening'),
];
