import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_color.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/core/theme/app_theme.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/features/settings/settings_page.dart';
import 'package:runout/shared/widgets/match_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// ---------------------------------------------------------------------------

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pump(
  WidgetTester tester,
  SettingsNotifier notifier, {
  AppSettings settings = AppSettings.defaults,
}) async {
  await notifier.setThemeMode(settings.themeMode);
  await notifier.setAppColor(settings.appColor);
  await notifier.setTextScale(settings.textScale);

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsNotifier>.value(
      value: notifier,
      child: const _ThemedApp(),
    ),
  );
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const Scaffold(body: SettingsPage()),
    );
  }
}

// ---------------------------------------------------------------------------

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;
  late SettingsRepository repository;
  late SettingsNotifier notifier;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    repository = SettingsRepository(SharedPreferencesAsync());
    notifier = SettingsNotifier(repository);
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
    notifier.dispose();
  });

  testWidgets('shows theme, color, and text size choices', (tester) async {
    await _pump(tester, notifier);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Text Size'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.byType(MatchCard), findsOneWidget);
    for (final label in ['System', 'Light', 'Dark', 'Blue', 'Green']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('shows the current choices as selected', (tester) async {
    await _pump(
      tester,
      notifier,
      settings: const AppSettings(
        themeMode: ThemeMode.dark,
        appColor: AppColor.blue,
        textScale: 1.5,
      ),
    );

    expect(find.widgetWithText(FilledButton, 'Dark'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Blue'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Light'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Green'), findsOneWidget);
    expect(find.text('150%'), findsOneWidget);
  });

  testWidgets('selecting a theme updates the app theme', (tester) async {
    await _pump(tester, notifier);

    expect(_brightness(tester), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(notifier.themeMode, ThemeMode.dark);
    expect(_brightness(tester), Brightness.dark);
  });

  testWidgets('selecting a color updates the app theme', (tester) async {
    await _pump(tester, notifier);

    final primaryBefore = _primary(tester);

    await tester.tap(find.text('Green'));
    await tester.pumpAndSettle();

    expect(notifier.appColor, AppColor.green);
    expect(_primary(tester), isNot(primaryBefore));
  });

  testWidgets('text scale slider updates the app text scale', (tester) async {
    await _pump(tester, notifier);

    final previewHeight = tester.getSize(find.text('Efren Reyes')).height;
    expect(_textScale(tester), 1);

    await tester.drag(find.byType(Slider), const Offset(1000, 0));
    await tester.pumpAndSettle();

    expect(notifier.textScale, AppSettings.maxTextScale);
    expect(find.text('150%'), findsOneWidget);
    expect(_textScale(tester), AppSettings.maxTextScale);
    expect(
      tester.getSize(find.text('Efren Reyes')).height,
      greaterThan(previewHeight),
    );
  });

  testWidgets('does not overflow at compact width and large text', (
    tester,
  ) async {
    _setSize(tester, const Size(375, 800));

    await _pump(
      tester,
      notifier,
      settings: AppSettings.defaults.copyWith(
        textScale: AppSettings.maxTextScale,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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

double _textScale(WidgetTester tester) {
  final ctx = tester.element(find.byType(SettingsPage));
  return MediaQuery.textScalerOf(ctx).scale(1);
}
