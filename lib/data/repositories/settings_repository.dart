import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and restores app settings.
///
/// Enum values are stored by name. Unknown or missing values fall back to
/// [AppSettings.defaults], so adding a value in a later version is safe.
class SettingsRepository {
  new(this._preferences);

  static const String _themeModeKey = 'settings.themeMode';
  static const String _appColorKey = 'settings.appColor';
  static const String _textScaleKey = 'settings.textScale';

  final SharedPreferencesAsync _preferences;

  /// Loads the saved settings, using defaults for missing or invalid values.
  Future<AppSettings> load() async {
    final values = await _preferences.getAll(
      allowList: {_themeModeKey, _appColorKey, _textScaleKey},
    );
    final themeModeName = _stringOrNull(values[_themeModeKey]);
    final appColorName = _stringOrNull(values[_appColorKey]);

    return AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[themeModeName] ??
          AppSettings.defaults.themeMode,
      appColor:
          AppColor.values.asNameMap()[appColorName] ??
          AppSettings.defaults.appColor,
      textScale: _textScaleOrDefault(values[_textScaleKey]),
    );
  }

  /// Saves the selected theme mode.
  Future<void> saveThemeMode(ThemeMode value) {
    return _preferences.setString(_themeModeKey, value.name);
  }

  /// Saves the selected app color.
  Future<void> saveAppColor(AppColor value) {
    return _preferences.setString(_appColorKey, value.name);
  }

  /// Saves the selected text scale.
  Future<void> saveTextScale(double value) {
    return _preferences.setDouble(_textScaleKey, value);
  }
}

String? _stringOrNull(Object? value) => value is String ? value : null;

double _textScaleOrDefault(Object? value) {
  if (value is! num || !value.isFinite) {
    return AppSettings.defaults.textScale;
  }

  return value.toDouble().clamp(
    AppSettings.minTextScale,
    AppSettings.maxTextScale,
  );
}
