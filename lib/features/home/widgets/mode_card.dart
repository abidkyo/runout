import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_color_scheme.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';

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
    return Semantics(
      button: true,
      child: Card(
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
                  color: context.colors.modeIcon,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: context.textTheme.modeTitle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
