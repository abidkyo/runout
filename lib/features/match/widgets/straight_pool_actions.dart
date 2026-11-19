import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/new_rack_picker_dialog.dart';
import 'package:runout/features/match/widgets/remaining_picker_dialog.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

/// Straight-pool controls: End visit, remaining count, New rack.
///
/// Visible only while the match is playing; the visibility gate lives in
/// the parent (`ControlsBar`).
class StraightPoolActions extends StatelessWidget {
  const new({super.key});

  // The two flags are mutually exclusive: a third foul forces keepsTurn, so
  // the innings branch is skipped and only notifyThreeFouls can fire.
  void _maybeNotify(BuildContext context) {
    final notifier = context.read<MatchNotifier>();

    if (notifier.notifyExtension) {
      notifier.notifyExtension = false;
      final limit = notifier.match.effectiveInningsLimit;
      showAppSnackBar(
        context,
        'Tied — ${MatchDefaults.inningsExtension} more innings '
        '(total $limit innings)',
      );
      return;
    }

    if (notifier.notifyThreeFouls) {
      notifier.notifyThreeFouls = false;
      showAppSnackBar(
        context,
        'Third fouls — ${MatchDefaults.threeFoulsPenalty} point '
        'penalty, re-rack',
      );
      return;
    }
  }

  void _endInning(BuildContext context) {
    context.read<MatchNotifier>().endVisit();
    _maybeNotify(context);
  }

  Future<void> _openScoreDialog(BuildContext context) async {
    final notifier = context.read<MatchNotifier>();
    final match = notifier.match;

    final result = await showDialog<RemainingResult>(
      context: context,
      builder: (_) => RemainingPickerDialog(
        remaining: match.ballsRemaining,
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
    _maybeNotify(context);
  }

  Future<void> _newRack(BuildContext context, {int? remaining}) async {
    final notifier = context.read<MatchNotifier>();

    final newRemaining =
        remaining ??
        await showDialog<int>(
          context: context,
          builder: (_) => const NewRackPickerDialog(),
        );
    if (newRemaining == null) return;

    final points = notifier.match.ballsRemaining - newRemaining;
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
      barrierDismissible: false,
    );

    if (!shouldContinue) {
      // Undo the kept-turn score, then re-apply as a visit-ending score.
      // The notifier can't mutate the last history entry in place, so this
      // is undo + redo with different flags.
      notifier
        ..undo()
        ..scoreVisit(points: points, ballsRemaining: newRemaining);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = context.watch<MatchNotifier>().match;

    final isPlaying = match.status == MatchStatus.playing;
    final ballsRemaining = match.ballsRemaining;

    return Visibility(
      key: const ValueKey('straight-pool-actions-visibility'),
      visible: isPlaying,
      child: Row(
        spacing: 16,
        children: [
          _LabelButton(
            body: const Icon(Icons.swap_horiz_rounded, size: 28),
            label: 'End inning',
            onPressed: () => _endInning(context),
          ),
          _LabelButton(
            body: Text(
              ballsRemaining.toString(),
              style: context.textTheme.titleLarge!.copyWith(
                color: context.colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              // will overflow on bigger textscale, so disabled it for now
              textScaler: TextScaler.noScaling,
            ),
            label: 'Balls',
            onPressed: () => _openScoreDialog(context),
            // style: TextButton.styleFrom(
            //   textStyle: context.textTheme.remainingLabel,
            // ),
          ),
          _LabelButton(
            body: const Icon(Icons.change_history_rounded, size: 28),
            label: 'New rack',
            onPressed: () => _newRack(context, remaining: 1),
            onLongPress: () => _newRack(context),
          ),
        ],
      ),
    );
  }
}

class _LabelButton extends StatelessWidget {
  const new({
    required this.body,
    required this.onPressed,
    this.label,
    this.onLongPress,
  });

  final Widget body;
  final String? label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final label = this.label;

    return FilledButton.tonal(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: FilledButton.styleFrom(
        minimumSize: const Size(128, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          body,
          if (label != null) Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}
