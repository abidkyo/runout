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
  AppSettings _settings = AppSettings.defaults;

  /// Loads the saved settings into [settings].
  ///
  /// Missing or invalid values fall back to [AppSettings.defaults].
  Future<void> load() async {
    final values = await _preferences.getAll(
      allowList: {_themeModeKey, _appColorKey, _textScaleKey},
    );
    final themeModeName = _stringOrNull(values[_themeModeKey]);
    final appColorName = _stringOrNull(values[_appColorKey]);

    _settings = AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[themeModeName] ??
          AppSettings.defaults.themeMode,
      appColor:
          AppColor.values.asNameMap()[appColorName] ??
          AppSettings.defaults.appColor,
      textScale: _textScaleOrDefault(values[_textScaleKey]),
    );
  }

  /// The settings loaded by [load], or the defaults before it runs.
  AppSettings get settings => _settings;

  /// Saves the selected theme mode and updates [settings].
  Future<void> saveThemeMode(ThemeMode value) async {
    await _preferences.setString(_themeModeKey, value.name);
    _settings = _settings.copyWith(themeMode: value);
  }

  /// Saves the selected app color and updates [settings].
  Future<void> saveAppColor(AppColor value) async {
    await _preferences.setString(_appColorKey, value.name);
    _settings = _settings.copyWith(appColor: value);
  }

  /// Saves the selected text scale and updates [settings].
  ///
  /// The value is clamped to the allowed range.
  Future<void> saveTextScale(double value) async {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Text scale must be finite');
    }

    final scale = value.clamp(
      AppSettings.minTextScale,
      AppSettings.maxTextScale,
    );
    await _preferences.setDouble(_textScaleKey, scale);
    _settings = _settings.copyWith(textScale: scale);
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
