import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/features/match/widgets/icon_label_button.dart';

/// Discard, setup, and home controls for the match page.
class NavigationButtons extends StatelessWidget {
  const new({
    required this.onDiscard,
    required this.onEdit,
    required this.onExit,
    super.key,
  });

  final VoidCallback onDiscard;
  final VoidCallback onEdit;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconLabelButton(
          icon: Icons.delete_rounded,
          label: 'Discard',
          onPressed: onDiscard,
          tooltip: 'Discard match',
          foregroundColor: context.colors.error,
        ),
        IconLabelButton(
          icon: Icons.tune_rounded,
          label: 'Setup',
          onPressed: onEdit,
          tooltip: 'Back to setup',
        ),
        IconLabelButton(
          icon: Icons.home_rounded,
          label: 'Home',
          onPressed: onExit,
          tooltip: 'Exit to home',
        ),
      ],
    );
  }
}
