import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_text_theme.dart';

/// A large tappable card representing a match mode on the home page.
class ModeCard extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Icon shown above the label.
  final IconData icon;

  /// Text label shown on the card.
  final String label;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleLargeSolid,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
