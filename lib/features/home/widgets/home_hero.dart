import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// The home page welcome panel and primary action.
class HomeHero extends StatelessWidget {
  const new({
    required this.onNewMatch,
    super.key,
  });

  /// Called when the user starts a new match.
  final VoidCallback onNewMatch;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready for another game?',
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onNewMatch,
              icon: const Icon(Icons.add),
              label: const Text('New Match'),
            ),
          ],
        ),
      ),
    );
  }
}
