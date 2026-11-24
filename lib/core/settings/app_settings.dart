import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';

/// User-selectable app settings.
@immutable
class AppSettings {
  const new({
    required this.themeMode,
    required this.appColor,
    this.textScale = 1,
  }) : assert(
         textScale >= minTextScale && textScale <= maxTextScale,
         'textScale must be between $minTextScale and $maxTextScale.',
       );

  /// Lowest selectable text scale.
  static const double minTextScale = 1;

  /// Highest selectable text scale.
  static const double maxTextScale = 1.5;

  /// Settings used when nothing has been saved yet.
  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    appColor: AppColor.blue,
    textScale: 1,
  );

  /// Whether to follow the system, light, or dark theme.
  final ThemeMode themeMode;

  /// Seed color used by the app theme.
  final AppColor appColor;

  /// Text scale applied across the app.
  final double textScale;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({
    ThemeMode? themeMode,
    AppColor? appColor,
    double? textScale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      appColor: appColor ?? this.appColor,
      textScale: textScale ?? this.textScale,
    );
  }
}
