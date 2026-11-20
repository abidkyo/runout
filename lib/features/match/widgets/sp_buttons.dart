import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/straight_pool_scoring.dart';

/// Straight-pool controls: End inning, balls count, New rack.
///
/// Visible only while the match is playing; the visibility gate lives in
/// the parent (`ControlsBar`).
class SPButtons extends StatelessWidget {
  const new({super.key});

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
            onPressed: () => _actions(context).endInning(context),
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
            onPressed: () => _actions(context).openScoringDialog(context),
            // style: TextButton.styleFrom(
            //   textStyle: context.textTheme.remainingLabel,
            // ),
          ),
          _LabelButton(
            body: const Icon(Icons.change_history_rounded, size: 28),
            label: 'New rack',
            onPressed: () => _actions(context).newRack(context, remaining: 1),
          ),
        ],
      ),
    );
  }

  SPScoring _actions(BuildContext context) {
    return SPScoring(context.read<MatchNotifier>());
  }
}

class _LabelButton extends StatelessWidget {
  const new({
    required this.body,
    required this.onPressed,
    this.label,
  });

  final Widget body;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = this.label;

    return FilledButton.tonal(
      onPressed: onPressed,
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
