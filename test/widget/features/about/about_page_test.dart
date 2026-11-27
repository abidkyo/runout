import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_constants.dart';
import 'package:runout/features/about/about_page.dart';
import 'package:runout/shared/widgets/app_logo.dart';

Widget _host() {
  return const MaterialApp(home: AboutPage());
}

void main() {
  testWidgets('renders app information, privacy, and portfolio', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text(AppConstants.appTitle), findsOneWidget);
    expect(find.text(AppConstants.appSubtitle), findsOneWidget);
    expect(find.text(AppConstants.appDescription), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text(AppConstants.appVersion), findsOneWidget);
    expect(find.text('Licenses'), findsOneWidget);
    expect(find.text('Data & privacy'), findsOneWidget);
    expect(find.textContaining('no account'), findsOneWidget);
    expect(find.text(AppConstants.portfolioSite), findsOneWidget);
    expect(find.text(AppConstants.legalese), findsOneWidget);
  });

  testWidgets('opens the license page', (tester) async {
    await tester.pumpWidget(_host());

    await tester.tap(find.text('Licenses'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('fits a compact screen at 2x text scale', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppConstants.portfolioSite), findsOneWidget);
  });
}
