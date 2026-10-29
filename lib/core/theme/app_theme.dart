import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';

class AppTheme {
  // Private constructor to prevent instantiation.
  // AppTheme is a static-only holder for theme definitions.
  new _();

  static const Color _seed = Colors.blue;

  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextTheme.fontFamily,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
