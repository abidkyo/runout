import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/data/local/app_database.dart';
import 'package:runout/data/local/match_codec.dart';
import 'package:runout/domain/models/match.dart';

/// Provides access to known matches.
class MatchRepository {
  new(this._database);

  final AppDatabase _database;
  final List<Match> _matches = [];

  /// Loads all matches from the local database.
  ///
  /// Rows that cannot be decoded are skipped. Stored timestamps are UTC; the
  /// loaded model uses local timestamps, matching in-session matches.
  Future<void> load() async {
    final rows = await _database.select(_database.matches).get();
    final matches = <Match>[];

    for (final row in rows) {
      try {
        final match = MatchCodec.decode(row.matchJson);
        matches.add(
          match.copyWith(
            startedAt: match.startedAt?.toLocal(),
            endedAt: match.endedAt?.toLocal(),
          ),
        );
      } on Object catch (error) {
        debugPrint('Skipping match ${row.id}: $error');
      }
    }

    _matches
      ..clear()
      ..addAll(matches);
  }

  /// Returns playing matches, most recently started first.
  List<Match> getPlaying() {
    final matches =
        _matches.where((match) => match.status == MatchStatus.playing).toList()
          ..sort((a, b) => _compareDescending(a.startedAt, b.startedAt));

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
          ..sort((a, b) => _compareDescending(a.endedAt, b.endedAt));

    final result = limit == null ? matches : matches.take(limit);
    return List.unmodifiable(result);
  }

  /// Inserts or updates [match] as the current snapshot.
  ///
  /// Created matches are not stored. A playing or finished match must have a
  /// start time.
  Future<void> save(Match match) async {
    if (match.status == MatchStatus.created) return;

    final startedAt = match.startedAt;
    if (startedAt == null) {
      throw StateError('A playing or finished match needs a start time.');
    }

    final endedAt = match.endedAt;
    final matchJson = MatchCodec.encode(match);

    await _database
        .into(_database.matches)
        .insert(
          MatchesCompanion.insert(
            id: match.id,
            status: match.status.name,
            startedAt: startedAt.toUtc(),
            endedAt: Value(endedAt?.toUtc()),
            matchJson: matchJson,
            createdAt: clock.now().toUtc(),
          ),
          onConflict: DoUpdate(
            (old) => MatchesCompanion(
              status: Value(match.status.name),
              startedAt: Value(startedAt.toUtc()),
              endedAt: Value(endedAt?.toUtc()),
              matchJson: Value(matchJson),
            ),
          ),
        );

    final index = _matches.indexWhere((candidate) => candidate.id == match.id);
    if (index == -1) {
      _matches.add(match);
    } else {
      _matches[index] = match;
    }
  }

  /// Removes the match with [id], if present.
  Future<void> delete(String id) async {
    await (_database.delete(_database.matches)..where((table) {
          return table.id.equals(id);
        }))
        .go();

    _matches.removeWhere((match) => match.id == id);
  }

  static int _compareDescending(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    return b.compareTo(a);
  }
}
