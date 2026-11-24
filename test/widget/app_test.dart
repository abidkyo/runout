import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/app.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// ---------------------------------------------------------------------------

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

  testWidgets('app starts with the saved theme and color', (tester) async {
    await tester.pumpWidget(
      RunoutApp(
        settingsRepository: SettingsRepository(SharedPreferencesAsync()),
        initialSettings: const AppSettings(
          themeMode: ThemeMode.dark,
          appColor: AppColor.blue,
        ),
      ),
    );

    final theme = Theme.of(tester.element(find.byType(HomePage)));
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.colorScheme.primary,
      AppTheme.dark(AppColor.blue).colorScheme.primary,
    );
  });

  testWidgets('settings tab changes the app theme and saves it', (
    tester,
  ) async {
    final repository = SettingsRepository(SharedPreferencesAsync());

    await tester.pumpWidget(
      RunoutApp(
        settingsRepository: repository,
        initialSettings: AppSettings.defaults,
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(_brightness(tester), Brightness.dark);
    expect((await repository.load()).themeMode, ThemeMode.dark);
  });
}

// ---------------------------------------------------------------------------

Brightness _brightness(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return Theme.of(ctx).brightness;
}
