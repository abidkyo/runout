import 'package:flutter/material.dart';

/// A circular ball button used in match dialogs.
class BallButton extends StatelessWidget {
  const new({
    required this.value,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  /// The number shown on the ball.
  final int value;

  /// Called when tapped. Null renders the button disabled.
  final VoidCallback? onTap;

  /// Whether the ball is highlighted.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        fixedSize: const Size(56, 56),
        textStyle: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontSize: 12 * 1.5),
        backgroundColor: selected ? theme.colorScheme.primary : null,
        foregroundColor: selected ? theme.colorScheme.onPrimary : null,
      ),
      child: Text('$value'),
    );
  }
}
