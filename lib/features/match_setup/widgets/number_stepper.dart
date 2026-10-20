import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// A wide numeric stepper with ±1 and ±10 controls and long-press repeat.
class NumberStepper extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.leadingLabel,
    this.trailingLabel,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? leadingLabel;
  final String? trailingLabel;

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

    final labels = [
      if (widget.leadingLabel != null) widget.leadingLabel!,
      '${widget.value}',
      if (widget.trailingLabel != null) widget.trailingLabel!,
    ];

    return SizedBox(
      height: 44,
      width: 360,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(
            icon: Icons.keyboard_double_arrow_left,
            enabled: canDecrease,
            onTap: () => _apply(-10),
            onLongPressStart: () => _startRepeat(-10),
            onLongPressEnd: _cancelTimer,
          ),
          _StepButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onTap: () => _apply(-1),
            onLongPressStart: () => _startRepeat(-1),
            onLongPressEnd: _cancelTimer,
          ),
          SizedBox(
            width: 150,
            child: Text(
              labels.join(' '),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            enabled: canIncrease,
            onTap: () => _apply(1),
            onLongPressStart: () => _startRepeat(1),
            onLongPressEnd: _cancelTimer,
          ),
          _StepButton(
            icon: Icons.keyboard_double_arrow_right,
            enabled: canIncrease,
            onTap: () => _apply(10),
            onLongPressStart: () => _startRepeat(10),
            onLongPressEnd: _cancelTimer,
          ),
        ],
      ),
    );
  }
}

/// A single stepper button, disabled when [enabled] is false.
class _StepButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    final borderColor = enabled
        ? theme.colorScheme.outline
        : theme.colorScheme.outline.withValues(alpha: 0.38);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPressStart : null,
        onLongPressUp: enabled ? onLongPressEnd : null,
        customBorder: const CircleBorder(),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
