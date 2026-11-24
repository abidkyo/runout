import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/features/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// ---------------------------------------------------------------------------

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Widget _host(SettingsNotifier notifier) {
  return ChangeNotifierProvider<SettingsNotifier>.value(
    value: notifier,
    child: const _ThemedApp(),
  );
}

SettingsNotifier _createNotifier({
  AppSettings settings = AppSettings.defaults,
}) {
  final notifier = SettingsNotifier(
    SettingsRepository(SharedPreferencesAsync()),
    initialSettings: settings,
  );
  addTearDown(notifier.dispose);
  return notifier;
}

class _ThemedApp extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return MaterialApp(
      theme: AppTheme.light(settings.appColor),
      darkTheme: AppTheme.dark(settings.appColor),
      themeMode: settings.themeMode,
      home: const Scaffold(body: SettingsPage()),
    );
  }
}

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

  testWidgets('shows theme and color choices', (tester) async {
    await tester.pumpWidget(_host(_createNotifier()));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    for (final label in ['System', 'Light', 'Dark', 'Blue', 'Green']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('shows the current choices as selected', (tester) async {
    await tester.pumpWidget(
      _host(
        _createNotifier(
          settings: const AppSettings(
            themeMode: ThemeMode.dark,
            appColor: AppColor.blue,
          ),
        ),
      ),
    );

    expect(find.widgetWithText(FilledButton, 'Dark'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Blue'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Light'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Green'), findsOneWidget);
  });

  testWidgets('selecting a theme updates the app theme', (tester) async {
    final notifier = _createNotifier();
    await tester.pumpWidget(_host(notifier));

    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(notifier.themeMode, ThemeMode.dark);
    expect(_brightness(tester), Brightness.dark);
  });

  testWidgets('selecting a color updates the app theme', (tester) async {
    final notifier = _createNotifier();
    await tester.pumpWidget(_host(notifier));

    final primaryBefore = _primary(tester);

    await tester.tap(find.text('Green'));
    await tester.pumpAndSettle();

    expect(notifier.appColor, AppColor.green);
    expect(_primary(tester), isNot(primaryBefore));
  });

  testWidgets('does not overflow at compact width and large text', (
    tester,
  ) async {
    _setSize(tester, const Size(375, 800));

    for (final scale in [1.5, 2.0]) {
      _setTextScale(tester, scale);
      await tester.pumpWidget(_host(_createNotifier()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });
}

Brightness _brightness(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return Theme.of(ctx).brightness;
}

Color _primary(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return Theme.of(ctx).colorScheme.primary;
}
