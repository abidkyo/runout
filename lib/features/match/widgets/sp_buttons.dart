import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Straight-pool controls: End inning, balls count, New rack.
class SPButtons extends StatelessWidget {
  const new({
    required this.ballsRemaining,
    required this.onEndInning,
    required this.onOpenScoring,
    required this.onNewRack,
    super.key,
  });

  final int ballsRemaining;
  final VoidCallback onEndInning;
  final VoidCallback onOpenScoring;
  final VoidCallback onNewRack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        _LabelButton(
          body: const Icon(Icons.swap_horiz_rounded, size: 28),
          label: 'End inning',
          onPressed: onEndInning,
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
          onPressed: onOpenScoring,
        ),
        _LabelButton(
          body: const Icon(Icons.change_history_rounded, size: 28),
          label: 'New rack',
          onPressed: onNewRack,
        ),
      ],
    );
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

    return SizedBox(
      width: 128,
      height: 60,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            body,
            if (label != null)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
