import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:runout/core/constants/persistence_defaults.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';

/// Keeps the stored match in sync with [MatchNotifier].
///
/// Changes are queued on one serial future tail, so a save and a following
/// discard cannot race. [discard] marks the session first, which makes pending
/// writes delete instead of save.
class MatchPersistence {
  new({
    required this.notifier,
    required this.repository,
    required this.onChanged,
    required this.onError,
    this.saveInitial = false,
    this.retryDelay = PersistenceDefaults.retryDelay,
    this.maxAttempts = PersistenceDefaults.maxAttempts,
  }) {
    notifier.addListener(_onMatchChanged);
    if (saveInitial) _enqueueReconcile();
  }

  final MatchNotifier notifier;
  final MatchRepository repository;
  final VoidCallback onChanged;
  final void Function(String message) onError;

  /// Whether to enqueue a write for the current state when created.
  ///
  /// Used when a paused match is resumed before this session is constructed.
  final bool saveInitial;
  final Duration retryDelay;
  final int maxAttempts;

  Future<void> _tail = Future<void>.value();
  bool _isDisposed = false;
  bool _isDiscarded = false;
  bool _isReconcileQueued = false;

  void _onMatchChanged() {
    if (_isDisposed || _isDiscarded) return;
    _enqueueReconcile();
  }

  void _enqueueReconcile() {
    if (_isReconcileQueued) return;

    _isReconcileQueued = true;
    _tail = _tail.then((_) async {
      _isReconcileQueued = false;
      await _reconcileSafely();
    });
  }

  /// Retries transient database failures, then reports one message.
  Future<void> _reconcileSafely() async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _reconcile();
      } on Object catch (error) {
        debugPrint('Match persistence attempt $attempt failed: $error');
        if (attempt == maxAttempts) {
          _reportError();
          return;
        }
        await Future<void>.delayed(retryDelay);
        continue;
      }

      _notifyChanged();
      return;
    }
  }

  void _notifyChanged() {
    try {
      onChanged();
    } on Object catch (error) {
      debugPrint('Failed to refresh match lists: $error');
    }
  }

  void _reportError() {
    try {
      onError(_errorMessage);
    } on Object catch (error) {
      debugPrint('Failed to report match persistence error: $error');
    }
  }

  String get _errorMessage {
    if (_isDiscarded) return 'Could not discard match.';

    return switch (notifier.match.status) {
      MatchStatus.finished => 'Could not save match.',
      MatchStatus.playing => 'Could not save match progress.',
      MatchStatus.created => 'Could not update match history.',
    };
  }

  /// Brings storage in line with the current match state.
  Future<void> _reconcile() async {
    final match = notifier.match;
    if (_isDiscarded || match.status == MatchStatus.created) {
      await repository.delete(match.id);
      return;
    }

    await repository.save(match);
  }

  /// Stops autosaving and deletes the stored match.
  ///
  /// Pending writes run first, but they observe the discarded flag and delete
  /// instead of saving. Failures are reported through [onError].
  Future<void> discard() {
    if (_isDiscarded) return _tail;
    _isDiscarded = true;
    _enqueueReconcile();
    return _tail;
  }

  /// Stops listening and completes when pending writes settle.
  Future<void> dispose() {
    if (_isDisposed) return _tail;
    _isDisposed = true;
    notifier.removeListener(_onMatchChanged);
    return _tail;
  }
}
