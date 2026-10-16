import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';

/// Tracks the elapsed time of a [MatchNotifier]'s match.
///
/// Follows [MatchNotifier] via `addListener`, diffs the status field and only
/// notifies its own listeners when it changes. A [Timer.periodic] ticks once
/// per second while match is playing, so the displayed elapsed time advances.
class MatchTimerNotifier extends ChangeNotifier {
  new(this._matchNotifier) {
    _status = _matchNotifier.match.status;
    _startedAt = _matchNotifier.match.startedAt;
    _endedAt = _matchNotifier.match.endedAt;

    _matchNotifier.addListener(_onMatchChanged);
    _syncTicker();
  }

  final MatchNotifier _matchNotifier;

  late MatchStatus _status;
  late DateTime? _startedAt;
  late DateTime? _endedAt;

  Timer? _ticker;

  /// Elapsed time of the match.
  ///
  /// Zero if the match hasn't started. Uses `endedAt` when the match has
  /// finished, `clock.now()` while playing.
  Duration get elapsed {
    final start = _startedAt;
    if (start == null) return Duration.zero;
    final end = _endedAt ?? clock.now();
    return end.difference(start);
  }

  /// Formats a [Duration] as `MM:SS`, or `HH:MM:SS` once the duration reaches
  /// an hour.
  String get formatted {
    final e = elapsed;
    final h = e.inHours;
    final m = e.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = e.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  void _onMatchChanged() {
    final match = _matchNotifier.match;
    if (_status == match.status) return;

    _status = match.status;
    _startedAt = match.startedAt;
    _endedAt = match.endedAt;
    _syncTicker();
    notifyListeners();
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (_status == MatchStatus.playing) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _matchNotifier.removeListener(_onMatchChanged);
    super.dispose();
  }
}
