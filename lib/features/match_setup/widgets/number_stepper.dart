import 'dart:async';

import 'package:flutter/material.dart';

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          label: '−−',
          enabled: canDecrease,
          onTap: () => _apply(-10),
          onLongPressStart: () => _startRepeat(-10),
          onLongPressEnd: _cancelTimer,
        ),
        const SizedBox(width: 12),
        _StepButton(
          label: '−',
          enabled: canDecrease,
          onTap: () => _apply(-1),
          onLongPressStart: () => _startRepeat(-1),
          onLongPressEnd: _cancelTimer,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 160,
          child: Text(
            '${widget.leadingLabel ?? ''}'
            ' ${widget.value} '
            '${widget.trailingLabel ?? ''}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 12),
        _StepButton(
          label: '+',
          enabled: canIncrease,
          onTap: () => _apply(1),
          onLongPressStart: () => _startRepeat(1),
          onLongPressEnd: _cancelTimer,
        ),
        const SizedBox(width: 12),
        _StepButton(
          label: '++',
          enabled: canIncrease,
          onTap: () => _apply(10),
          onLongPressStart: () => _startRepeat(10),
          onLongPressEnd: _cancelTimer,
        ),
      ],
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
    final theme = Theme.of(context);
    final color = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPressStart : null,
        onLongPressUp: enabled ? onLongPressEnd : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
