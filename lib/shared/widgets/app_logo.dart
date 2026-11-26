import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_constants.dart';
import 'package:runout/core/theme/theme_extension.dart';

// Runout logo.
class AppLogo extends StatelessWidget {
  const new({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppConstants.iconPath,
      height: size,
      semanticsLabel: 'Runout Logo',
      colorFilter: ColorFilter.mode(
        context.colors.primary,
        BlendMode.srcIn,
      ),
    );
  }
}
