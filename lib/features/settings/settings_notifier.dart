import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/data/repositories/settings_repository.dart';

/// Holds the app settings and persists changes.
class SettingsNotifier extends ChangeNotifier {
  new(
    this._repository, {
    required AppSettings initialSettings,
  }) : _settings = initialSettings;

  final SettingsRepository _repository;
  AppSettings _settings;

  /// The current app settings.
  AppSettings get settings => _settings;

  /// Whether to follow the system, light, or dark theme.
  ThemeMode get themeMode => _settings.themeMode;

  /// Seed color used by the app theme.
  AppColor get appColor => _settings.appColor;

  /// Text scale applied across the app.
  double get textScale => _settings.textScale;

  /// Selects the theme mode and persists it.
  Future<void> setThemeMode(ThemeMode value) async {
    if (_settings.themeMode == value) return;
    _settings = _settings.copyWith(themeMode: value);
    notifyListeners();
    await _save(() => _repository.saveThemeMode(value));
  }

  /// Selects the app color and persists it.
  Future<void> setAppColor(AppColor value) async {
    if (_settings.appColor == value) return;
    _settings = _settings.copyWith(appColor: value);
    notifyListeners();
    await _save(() => _repository.saveAppColor(value));
  }

  /// Selects the text scale and persists it.
  Future<void> setTextScale(double value) async {
    if (!value.isFinite) return;

    final scale = value.clamp(
      AppSettings.minTextScale,
      AppSettings.maxTextScale,
    );
    if (_settings.textScale == scale) return;
    _settings = _settings.copyWith(textScale: scale);
    notifyListeners();
    await _save(() => _repository.saveTextScale(scale));
  }

  Future<void> _save(Future<void> Function() save) async {
    try {
      await save();
    } on Object catch (error) {
      debugPrint('Failed to save settings: $error');
    }
  }
}
