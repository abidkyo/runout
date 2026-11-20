import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/icon_label_button.dart';

/// Setup and home navigation controls for the match page.
class NavigationButtons extends StatelessWidget {
  const new({
    required this.onRestart,
    required this.onExit,
    super.key,
  });

  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconLabelButton(
          icon: Icons.tune_rounded,
          label: 'Setup',
          onPressed: onRestart,
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
