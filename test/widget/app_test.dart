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

import '../unit/helpers/fake_repositories.dart';

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

  testWidgets('app starts with the saved settings', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      RunoutApp(
        settingsRepository: SettingsRepository(SharedPreferencesAsync()),
        initialSettings: const AppSettings(
          themeMode: ThemeMode.dark,
          appColor: AppColor.blue,
          textScale: 1.5,
        ),
        playerRepository: FakePlayerRepository(),
        matchRepository: FakeMatchRepository(),
      ),
    );

    final context = tester.element(find.byType(HomePage));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.colorScheme.primary,
      AppTheme.dark(AppColor.blue).colorScheme.primary,
    );
    expect(MediaQuery.textScalerOf(context).scale(1), 1.5);
  });

  testWidgets('settings tab changes the app theme and saves it', (
    tester,
  ) async {
    final repository = SettingsRepository(SharedPreferencesAsync());
    await _pump(tester, settingsRepository: repository);

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(_brightness(tester), Brightness.dark);
    expect((await repository.load()).themeMode, ThemeMode.dark);
  });

  testWidgets('settings tab changes the text scale and saves it', (
    tester,
  ) async {
    final repository = SettingsRepository(SharedPreferencesAsync());
    await _pump(tester, settingsRepository: repository);

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(Slider));
    await tester.drag(find.byType(Slider), const Offset(1000, 0));
    await tester.pumpAndSettle();

    expect(_textScale(tester), AppSettings.maxTextScale);
    expect((await repository.load()).textScale, AppSettings.maxTextScale);
  });

  testWidgets('warns when storage is unavailable', (tester) async {
    await _pump(tester, isStorageUnavailable: true);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Storage unavailable. Changes will not be saved.'),
      findsOneWidget,
    );
  });
}

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  SettingsRepository? settingsRepository,
  bool isStorageUnavailable = false,
}) {
  return tester.pumpWidget(
    RunoutApp(
      settingsRepository:
          settingsRepository ?? SettingsRepository(SharedPreferencesAsync()),
      initialSettings: AppSettings.defaults,
      playerRepository: FakePlayerRepository(),
      matchRepository: FakeMatchRepository(),
      isStorageUnavailable: isStorageUnavailable,
    ),
  );
}

Brightness _brightness(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return Theme.of(ctx).brightness;
}

double _textScale(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return MediaQuery.textScalerOf(ctx).scale(1);
}
