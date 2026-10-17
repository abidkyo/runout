import 'package:material_ui/material_ui.dart';

/// Large tappable button used to select the breaking side before a match.
class BreakButton extends StatelessWidget {
  const new({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        textStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      child: const Text('Who breaks?'),
    );
  }
}
