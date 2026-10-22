import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';

/// Large tappable button used to select the breaking side before a match.
class BreakButton extends StatelessWidget {
  const new({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(textStyle: theme.textTheme.titleLargeSolid),
      child: const Text('Who breaks?'),
    );
  }
}
