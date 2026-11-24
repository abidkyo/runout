import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';

/// User-selectable app settings.
@immutable
class AppSettings {
  const new({required this.themeMode, required this.appColor});

  /// Settings used when nothing has been saved yet.
  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    appColor: AppColor.blue,
  );

  /// Whether to follow the system, light, or dark theme.
  final ThemeMode themeMode;

  /// Seed color used by the app theme.
  final AppColor appColor;

  /// Returns a copy with the given fields replaced.
  AppSettings copyWith({ThemeMode? themeMode, AppColor? appColor}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      appColor: appColor ?? this.appColor,
    );
  }
}
