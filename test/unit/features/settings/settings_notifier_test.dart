import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/settings/settings_notifier.dart';
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

  Future<SettingsNotifier> createNotifier(
    SettingsRepository repository,
  ) async {
    await repository.load();
    final notifier = SettingsNotifier(repository);
    addTearDown(notifier.dispose);
    return notifier;
  }

  group('initial state', () {
    test('uses the loaded defaults', () async {
      final notifier = await createNotifier(
        SettingsRepository(SharedPreferencesAsync()),
      );

      expect(notifier.themeMode, AppSettings.defaults.themeMode);
      expect(notifier.appColor, AppSettings.defaults.appColor);
      expect(notifier.textScale, AppSettings.defaults.textScale);
    });

    test('uses saved settings', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            'settings.themeMode': 'dark',
            'settings.appColor': 'green',
            'settings.textScale': 1.2,
          });

      final notifier = await createNotifier(
        SettingsRepository(SharedPreferencesAsync()),
      );

      expect(notifier.themeMode, ThemeMode.dark);
      expect(notifier.appColor, AppColor.green);
      expect(notifier.textScale, 1.2);
    });
  });

  group('setters', () {
    test('theme mode updates, notifies, and persists', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = await createNotifier(repository);
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.themeMode, ThemeMode.dark);
      expect(notifyCount, 1);
      expect(repository.settings.themeMode, ThemeMode.dark);
      await repository.load();
      expect(repository.settings.themeMode, ThemeMode.dark);
    });

    test('app color updates, notifies, and persists', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = await createNotifier(repository);
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setAppColor(AppColor.green);

      expect(notifier.appColor, AppColor.green);
      expect(notifyCount, 1);
      expect(repository.settings.appColor, AppColor.green);
      await repository.load();
      expect(repository.settings.appColor, AppColor.green);
    });

    test('text scale updates, notifies, and persists', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = await createNotifier(repository);
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setTextScale(1.2);

      expect(notifier.textScale, 1.2);
      expect(notifyCount, 1);
      expect(repository.settings.textScale, 1.2);
      await repository.load();
      expect(repository.settings.textScale, 1.2);
    });

    test('text scale clamps to the allowed range', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = await createNotifier(repository);

      await notifier.setTextScale(3);

      expect(notifier.textScale, AppSettings.maxTextScale);
      expect(repository.settings.textScale, AppSettings.maxTextScale);
    });

    test('same value does not notify or write', () async {
      final preferences = SharedPreferencesAsync();
      final notifier = await createNotifier(SettingsRepository(preferences));
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(AppSettings.defaults.themeMode);
      await notifier.setAppColor(AppSettings.defaults.appColor);
      await notifier.setTextScale(AppSettings.defaults.textScale);

      expect(notifyCount, 0);
      expect(await preferences.getAll(), isEmpty);
    });

    test('write failure keeps the selected value', () async {
      SharedPreferencesAsyncPlatform.instance = _ThrowingPreferences();
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = await createNotifier(repository);

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.themeMode, ThemeMode.dark);
      expect(repository.settings.themeMode, AppSettings.defaults.themeMode);
    });
  });
}

// ---------------------------------------------------------------------------

base class _ThrowingPreferences extends InMemorySharedPreferencesAsync {
  new() : super.empty();

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    throw Exception('write failed');
  }
}
