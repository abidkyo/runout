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

  group('load', () {
    test('uses defaults when nothing is stored', () async {
      final settings = await createRepository().load();

      expect(settings.themeMode, AppSettings.defaults.themeMode);
      expect(settings.appColor, AppSettings.defaults.appColor);
    });

    test('reads stored values', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'settings.themeMode': 'dark',
            'settings.appColor': 'blue',
          });

      final settings = await createRepository().load();

      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.appColor, AppColor.blue);
    });

    test('falls back for unknown values', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'settings.themeMode': 'sepia',
            'settings.appColor': 'red',
          });

      final settings = await createRepository().load();

      expect(settings.themeMode, AppSettings.defaults.themeMode);
      expect(settings.appColor, AppSettings.defaults.appColor);
    });

    test('falls back for values stored with another type', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'settings.themeMode': 1});

      final settings = await createRepository().load();

      expect(settings.themeMode, AppSettings.defaults.themeMode);
    });
  });

  group('save', () {
    test('writes theme mode and app color', () async {
      final preferences = SharedPreferencesAsync();
      final repository = SettingsRepository(preferences);

      await repository.saveThemeMode(ThemeMode.dark);
      await repository.saveAppColor(AppColor.blue);

      expect(await preferences.getString('settings.themeMode'), 'dark');
      expect(await preferences.getString('settings.appColor'), 'blue');
    });

    test('round-trips saved values', () async {
      final repository = createRepository();

      await repository.saveThemeMode(ThemeMode.light);
      await repository.saveAppColor(AppColor.blue);

      final settings = await repository.load();

      expect(settings.themeMode, ThemeMode.light);
      expect(settings.appColor, AppColor.blue);
    });
  });
}
