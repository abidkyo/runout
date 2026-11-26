import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';

/// Tracks the actual play time of a [MatchNotifier]'s match.
///
/// Follows [MatchNotifier] via `addListener` and reports the match's elapsed
/// time excluding paused time. A [Timer.periodic] ticks once per second while
/// the match is playing and not paused.
class MatchTimerNotifier extends ChangeNotifier {
  new(this._matchNotifier) {
    _match = _matchNotifier.match;
    _status = _match.status;

    _matchNotifier.addListener(_onMatchChanged);
    _syncTicker();
  }

  final MatchNotifier _matchNotifier;

  late Match _match;
  late MatchStatus _status;

  Timer? _ticker;

  /// Actual elapsed play time, excluding paused time.
  ///
  /// Zero if the match hasn't started.
  Duration get elapsed => _match.elapsedAt(clock.now());

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
    final timingChanged =
        _match.startedAt != match.startedAt ||
        _match.endedAt != match.endedAt ||
        _match.pausedAt != match.pausedAt ||
        _match.totalPausedSeconds != match.totalPausedSeconds;
    if (_status == match.status && !timingChanged) return;

    _match = match;
    _status = match.status;
    _syncTicker();
    notifyListeners();
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (_status == MatchStatus.playing && _match.pausedAt == null) {
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
