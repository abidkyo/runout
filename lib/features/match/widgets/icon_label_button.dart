import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// Icon with an optional label, collapsing to a tooltip on compact widths.
class IconLabelButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    final tooltip = this.tooltip;

    final button = SizedBox(
      width: isCompact ? 56 : 68,
      height: isCompact ? 56 : 60,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Icon(icon, size: 28),
            if (!isCompact)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return isCompact
        ? Tooltip(message: tooltip ?? label, child: button)
        : button;
  }
}
