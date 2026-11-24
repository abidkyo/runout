import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/theme/app_text_theme.dart';

class AppTheme {
  // Private constructor to prevent instantiation.
  // AppTheme is a static-only holder for theme definitions.
  new _();

  static ThemeData light(AppColor appColor) {
    return _theme(Brightness.light, appColor);
  }

  static ThemeData dark(AppColor appColor) {
    return _theme(Brightness.dark, appColor);
  }

  static ThemeData _theme(Brightness brightness, AppColor appColor) {
    final hsl = HSLColor.fromColor(appColor.seed);
    final tertiary = hsl.withHue((hsl.hue - 30) % 360).toColor();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: appColor.seed,
      brightness: brightness,
      tertiary: tertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextTheme.fontFamily,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
