import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// A circular ball button used in match dialogs.
class BallButton extends StatelessWidget {
  const new({
    required this.value,
    required this.onTap,
    this.selected = false,
    this.width = 60,
    super.key,
  });

  /// The number shown on the ball.
  final int value;

  /// Called when tapped. Null renders the button disabled.
  final VoidCallback? onTap;

  /// Whether the ball is highlighted.
  final bool selected;

  /// width/height of the button
  final double width;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        side: selected ? BorderSide.none : null,
        minimumSize: Size(width, width),
        textStyle: context.textTheme.ballLabel.copyWith(
          fontSize: width * 0.3,
        ),
        backgroundColor: selected ? context.colors.primary : null,
        foregroundColor: selected ? context.colors.onPrimary : null,
      ),
      child: Text('$value'),
    );
  }
}
