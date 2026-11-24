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

  SettingsNotifier createNotifier(SettingsRepository repository) {
    final notifier = SettingsNotifier(
      repository,
      initialSettings: AppSettings.defaults,
    );
    addTearDown(notifier.dispose);
    return notifier;
  }

  group('initial state', () {
    test('exposes the initial settings', () {
      final notifier = createNotifier(
        SettingsRepository(SharedPreferencesAsync()),
      );

      expect(notifier.themeMode, AppSettings.defaults.themeMode);
      expect(notifier.appColor, AppSettings.defaults.appColor);
    });
  });

  group('setters', () {
    test('theme mode updates, notifies, and persists', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = createNotifier(repository);
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.themeMode, ThemeMode.dark);
      expect(notifyCount, 1);
      expect((await repository.load()).themeMode, ThemeMode.dark);
    });

    test('app color updates, notifies, and persists', () async {
      final repository = SettingsRepository(SharedPreferencesAsync());
      final notifier = createNotifier(repository);
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setAppColor(AppColor.green);

      expect(notifier.appColor, AppColor.green);
      expect(notifyCount, 1);
      expect((await repository.load()).appColor, AppColor.green);
    });

    test('same value does not notify or write', () async {
      final preferences = SharedPreferencesAsync();
      final notifier = createNotifier(SettingsRepository(preferences));
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      await notifier.setThemeMode(AppSettings.defaults.themeMode);
      await notifier.setAppColor(AppSettings.defaults.appColor);

      expect(notifyCount, 0);
      expect(await preferences.getAll(), isEmpty);
    });

    test('write failure keeps the selected value', () async {
      SharedPreferencesAsyncPlatform.instance = _ThrowingPreferences();
      final notifier = createNotifier(
        SettingsRepository(SharedPreferencesAsync()),
      );

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.themeMode, ThemeMode.dark);
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
