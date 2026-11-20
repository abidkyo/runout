import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/sp_scoring_dialog.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

/// Straight-pool scoring actions shared by the controls and side cards.
class SPScoring {
  const new(this._notifier);

  final MatchNotifier _notifier;

  /// Opens the scoring dialog and applies the selected result.
  Future<void> openScoringDialog(BuildContext context) async {
    final match = _notifier.match;

    final result = await showDialog<SPScoreResult>(
      context: context,
      builder: (_) => SPScoringDialog(
        remaining: match.ballsRemaining,
        showBreakFoul: match.isOpeningBreak,
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;

    if (result.remaining < 2) {
      await newRack(context, remaining: result.remaining);
      return;
    }

    _notifier.scoreRemaining(
      result.remaining,
      keepsTurn: result.keepsTurn,
      foul: result.foul,
    );

    if (!context.mounted) return;
    _maybeNotify(context);
  }

  /// Ends the visit or starts a new rack, then handles the target prompt.
  Future<void> newRack(
    BuildContext context, {
    required int remaining,
  }) async {
    final points = _notifier.match.ballsRemaining - remaining;
    _notifier.newRack(remaining);

    if (!_notifier.askToContinue) return;
    _notifier.askToContinue = false;

    if (!context.mounted) return;

    final shouldContinue = await showConfirmDialog(
      context,
      title: 'Target reached.',
      message:
          'The target score is reached. '
          'Do you want to continue playing?',
      confirmLabel: 'Continue',
      cancelLabel: 'End',
      barrierDismissible: false,
    );

    if (!shouldContinue) {
      // Undo the kept-turn score, then re-apply as a visit-ending score.
      // The notifier can't mutate the last history entry in place, so this
      // is undo + redo with different flags.
      _notifier
        ..undo()
        ..scoreVisit(points: points, ballsRemaining: remaining);
    }
  }

  /// Ends the current inning without scoring.
  void endInning(BuildContext context) {
    _notifier.endVisit();
    _maybeNotify(context);
  }

  void _maybeNotify(BuildContext context) {
    if (_notifier.notifyExtension) {
      _notifier.notifyExtension = false;
      final limit = _notifier.match.effectiveInningsLimit;
      showAppSnackBar(
        context,
        'Tied — ${MatchDefaults.inningsExtension} more innings '
        '(total $limit innings)',
      );
      return;
    }

    if (_notifier.notifyThreeFouls) {
      _notifier.notifyThreeFouls = false;
      showAppSnackBar(
        context,
        'Third fouls — ${MatchDefaults.threeFoulsPenalty} point '
        'penalty, re-rack',
      );
    }
  }
}
