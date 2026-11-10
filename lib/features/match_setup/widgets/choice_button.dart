import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// A single-select choice button, filled when selected.
class ChoiceButton extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final textStyle = context.textTheme.titleMedium;
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 20);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (icon != null) Icon(icon, size: 18),
        Flexible(
          child: Text(label, maxLines: 1, overflow: .ellipsis),
        ),
      ],
    );

    if (selected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(textStyle: textStyle, padding: padding),
        child: content,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(textStyle: textStyle, padding: padding),
      child: content,
    );
  }
}
