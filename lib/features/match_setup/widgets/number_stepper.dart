import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// A numeric stepper with ±1 and ±10 controls and long-press repeat.
class NumberStepper extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  Timer? _repeatTimer;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _startRepeat(int step) {
    _cancelTimer();
    _apply(step);
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _apply(step),
    );
  }

  void _apply(int step) {
    final next = (widget.value + step).clamp(widget.min, widget.max);
    if (next == widget.value) {
      // At bound — stop repeating.
      _cancelTimer();
      return;
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final canDecrease = widget.value > widget.min;
    final canIncrease = widget.value < widget.max;

    final valueText = Text(
      '${widget.value}',
      style: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
    );
    final decreaseTen = _StepButton(
      label: '-10',
      enabled: canDecrease,
      onTap: () => _apply(-10),
      onLongPressStart: () => _startRepeat(-10),
      onLongPressEnd: _cancelTimer,
    );
    final decreaseOne = _StepButton(
      label: '-1',
      enabled: canDecrease,
      onTap: () => _apply(-1),
      onLongPressStart: () => _startRepeat(-1),
      onLongPressEnd: _cancelTimer,
    );
    final increaseOne = _StepButton(
      label: '+1',
      enabled: canIncrease,
      onTap: () => _apply(1),
      onLongPressStart: () => _startRepeat(1),
      onLongPressEnd: _cancelTimer,
    );
    final increaseTen = _StepButton(
      label: '+10',
      enabled: canIncrease,
      onTap: () => _apply(10),
      onLongPressStart: () => _startRepeat(10),
      onLongPressEnd: _cancelTimer,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 350;

        if (isNarrow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              valueText,
              Column(
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [decreaseOne, increaseOne],
                  ),
                  Row(
                    spacing: 8,
                    children: [decreaseTen, increaseTen],
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Row(
              spacing: 8,
              children: [decreaseTen, decreaseOne],
            ),
            Expanded(child: valueText),
            Row(
              spacing: 8,
              children: [increaseOne, increaseTen],
            ),
          ],
        );
      },
    );
  }
}

/// A single stepper button, disabled when [enabled] is false.
class _StepButton extends StatelessWidget {
  const new({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final foreground = enabled
        ? colors.onSecondaryContainer
        : colors.onSurface.withValues(alpha: 0.38);

    final background = enabled
        ? colors.secondaryContainer
        : colors.surfaceContainerHighest;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPressStart : null,
        onLongPressUp: enabled ? onLongPressEnd : null,
        child: SizedBox(
          width: 60,
          height: 48,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge!.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
