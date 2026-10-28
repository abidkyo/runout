import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/new_rack_picker_dialog.dart';
import 'package:runout/features/match/widgets/remaining_picker_dialog.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

/// Straight-pool controls: End visit, remaining count, New rack.
///
/// Visible only while the match is playing; the visibility gate lives in
/// the parent (`ControlsBar`).
class StraightPoolActions extends StatelessWidget {
  const new({super.key});

  static const double _iconSize = 32;

  // The two flags are mutually exclusive: a third foul forces keepsTurn, so
  // the innings branch is skipped and only notifyThreeFouls can fire.
  void _maybeNotify(BuildContext context, MatchNotifier notifier) {
    if (notifier.notifyExtension) {
      notifier.notifyExtension = false;
      final limit = notifier.match.effectiveInningsLimit;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Tied — ${MatchDefaults.inningsExtension} more innings '
              '(total $limit innings)',
            ),
            showCloseIcon: true,
          ),
        );
      return;
    }

    if (notifier.notifyThreeFouls) {
      notifier.notifyThreeFouls = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Third fouls — ${MatchDefaults.threeFoulsPenalty} point '
              'penalty, re-rack',
            ),
            showCloseIcon: true,
          ),
        );
      return;
    }
  }

  void _endVisit(BuildContext context, MatchNotifier notifier) {
    notifier.endVisit();
    _maybeNotify(context, notifier);
  }

  Future<void> _pickRemaining(
    BuildContext context,
    MatchNotifier notifier,
  ) async {
    final match = notifier.match;

    final result = await showDialog<RemainingResult>(
      context: context,
      builder: (_) => RemainingPickerDialog(
        remaining: match.remaining,
        showBreakFoul: match.isOpeningBreak,
      ),
    );
    if (result == null) return;

    notifier.scoreRemaining(
      result.remaining,
      keepsTurn: result.keepsTurn,
      foul: result.foul,
    );

    if (!context.mounted) return;
    _maybeNotify(context, notifier);
  }

  Future<void> _newRack(
    BuildContext context,
    MatchNotifier notifier, {
    int? remaining,
  }) async {
    final newRemaining =
        remaining ??
        await showDialog<int>(
          context: context,
          builder: (_) => const NewRackPickerDialog(),
        );
    if (newRemaining == null) return;

    final points = notifier.match.remaining - newRemaining;
    notifier.newRack(newRemaining);

    if (!notifier.askToContinue) return;
    notifier.askToContinue = false;

    if (!context.mounted) return;

    final shouldContinue = await showConfirmDialog(
      context,
      title: 'Target reached.',
      message:
          'The target score is reached. '
          'Do you want to continue playing?',
      confirmLabel: 'Continue',
      cancelLabel: 'End',
    );

    if (!shouldContinue) {
      final sideIndex = notifier.match.currentBreakerIndex;
      if (sideIndex == null) return;

      // Undo the kept-turn score, then re-apply as a visit-ending score.
      // The notifier can't mutate the last history entry in place, so this
      // is undo + redo with different flags.
      notifier
        ..undo()
        ..incrementScore(sideIndex, points: points, remaining: newRemaining);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          iconSize: _iconSize,
          tooltip: 'End visit',
          onPressed: () => _endVisit(context, notifier),
        ),
        TextButton(
          onPressed: () => _pickRemaining(context, notifier),
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.titleLargeSolid,
          ),
          child: Tooltip(
            message: 'Balls remaining',
            child: Text('${match.remaining}'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.change_history),
          iconSize: _iconSize,
          tooltip: 'New rack',
          onPressed: () => _newRack(context, notifier, remaining: 1),
          onLongPress: () => _newRack(context, notifier),
        ),
      ],
    );
  }
}
