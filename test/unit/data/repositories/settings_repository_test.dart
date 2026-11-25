import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  SettingsRepository createRepository() =>
      SettingsRepository(SharedPreferencesAsync());

  group('settings', () {
    test('uses defaults before load', () {
      expect(createRepository().settings, AppSettings.defaults);
    });
  });

  group('load', () {
    test('uses defaults when nothing is stored', () async {
      final repository = createRepository();
      await repository.load();

      expect(repository.settings.themeMode, AppSettings.defaults.themeMode);
      expect(repository.settings.appColor, AppSettings.defaults.appColor);
      expect(repository.settings.textScale, AppSettings.defaults.textScale);
    });

    test('reads stored values', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'settings.themeMode': 'dark',
            'settings.appColor': 'blue',
            'settings.textScale': 1.5,
          });
      final repository = createRepository();

      await repository.load();

      expect(repository.settings.themeMode, ThemeMode.dark);
      expect(repository.settings.appColor, AppColor.blue);
      expect(repository.settings.textScale, 1.5);
    });

    test('falls back for unknown values', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'settings.themeMode': 'sepia',
            'settings.appColor': 'red',
            'settings.textScale': 'large',
          });
      final repository = createRepository();

      await repository.load();

      expect(repository.settings.themeMode, AppSettings.defaults.themeMode);
      expect(repository.settings.appColor, AppSettings.defaults.appColor);
      expect(repository.settings.textScale, AppSettings.defaults.textScale);
    });

    test('falls back for values stored with another type', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'settings.themeMode': 1});
      final repository = createRepository();

      await repository.load();

      expect(repository.settings.themeMode, AppSettings.defaults.themeMode);
    });

    test('clamps an out-of-range text scale', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'settings.textScale': 3.0});
      final repository = createRepository();

      await repository.load();

      expect(repository.settings.textScale, AppSettings.maxTextScale);
    });
  });

  group('save', () {
    test('writes values and updates the cached settings', () async {
      final preferences = SharedPreferencesAsync();
      final repository = SettingsRepository(preferences);

      await repository.saveThemeMode(ThemeMode.dark);
      await repository.saveAppColor(AppColor.green);
      await repository.saveTextScale(1.2);

      expect(repository.settings.themeMode, ThemeMode.dark);
      expect(repository.settings.appColor, AppColor.green);
      expect(repository.settings.textScale, 1.2);
      expect(await preferences.getString('settings.themeMode'), 'dark');
      expect(await preferences.getString('settings.appColor'), 'green');
      expect(await preferences.getDouble('settings.textScale'), 1.2);
    });

    test('clamps the saved text scale', () async {
      final preferences = SharedPreferencesAsync();
      final repository = SettingsRepository(preferences);

      await repository.saveTextScale(3);

      expect(repository.settings.textScale, AppSettings.maxTextScale);
      expect(
        await preferences.getDouble('settings.textScale'),
        AppSettings.maxTextScale,
      );
    });

    test('rejects a non-finite text scale', () async {
      final repository = createRepository();

      await expectLater(
        repository.saveTextScale(double.nan),
        throwsArgumentError,
      );
      expect(repository.settings.textScale, AppSettings.defaults.textScale);
    });

    test('round-trips saved values', () async {
      final repository = createRepository();

      await repository.saveThemeMode(ThemeMode.light);
      await repository.saveAppColor(AppColor.blue);
      await repository.saveTextScale(1.2);
      await repository.load();

      expect(repository.settings.themeMode, ThemeMode.light);
      expect(repository.settings.appColor, AppColor.blue);
      expect(repository.settings.textScale, 1.2);
    });
  });
}
