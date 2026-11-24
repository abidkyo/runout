import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// A single-select choice button, filled when selected.
class ChoiceButton extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.verticalPadding = 20, // this make 48px button
    this.leading,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Widget? leading;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final textStyle = context.textTheme.titleMedium;
    final padding = EdgeInsets.symmetric(
      horizontal: 8,
      vertical: verticalPadding,
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        ?leading,
        Flexible(
          child: Text(label, softWrap: false, overflow: .fade),
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
