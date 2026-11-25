import 'package:flutter/foundation.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';

/// Signals list screens to re-read stored matches after a write.
///
/// The repository stays data-only. MatchPersistence calls [refresh] after
/// successful saves and deletes.
class MatchListNotifier extends ChangeNotifier {
  new(this._repository);

  final MatchRepository _repository;

  /// Returns playing matches, most recently started first.
  List<Match> getPlaying() => _repository.getPlaying();

  /// Returns finished matches, most recently ended first.
  List<Match> getFinished({int? limit}) =>
      _repository.getFinished(limit: limit);

  /// Notifies listeners to re-read the repository.
  void refresh() => notifyListeners();
}
