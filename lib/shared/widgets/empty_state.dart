import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// A centered empty or placeholder state.
class EmptyState extends StatelessWidget {
  const new({
    required this.title,
    super.key,
    this.icon,
    this.message,
  });

  /// Short state title, for example "No finished matches".
  final String title;

  /// Optional supporting message.
  final String? message;

  /// Optional icon shown above the title.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
