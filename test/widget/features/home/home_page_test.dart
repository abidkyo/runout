import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/home/mode_card.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';

// ---------------------------------------------------------------------------

Widget _host() => const MaterialApp(
  home: HomePage(),
);

Future<void> _tapCard(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

MatchSetupPage _getPage(WidgetTester tester) {
  return tester.widget<MatchSetupPage>(
    find.byType(MatchSetupPage),
  );
}

/// MatchConfigPanel in MatchSetupPage requires ~960px width; the default
/// 800×600 test surface is too narrow. Use a landscape tablet viewport.
void _setTabletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// ---------------------------------------------------------------------------

void main() {
  group('HomePage', () {
    testWidgets('renders the app bar title', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.text('Runout'), findsOneWidget);
    });

    testWidgets('renders four mode cards', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byType(ModeCard), findsNWidgets(4));
    });

    testWidgets('renders the four mode labels', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.text('Singles'), findsOneWidget);
      expect(find.text('Doubles'), findsOneWidget);
      expect(find.text('Three Players'), findsOneWidget);
      expect(find.text('Tournament'), findsOneWidget);
    });

    testWidgets('renders the four mode icons', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    group('responsive', () {
      testWidgets('renders a single column below the compact breakpoint', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(
          LayoutBreakpoints.compact - 100,
          600,
        );
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_host());

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 1);
      });

      testWidgets('renders two columns at or above the compact breakpoint', (
        tester,
      ) async {
        await tester.pumpWidget(_host());

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
      });
    });

    group('navigation', () {
      testWidgets('tapping Singles opens MatchSetupPage with singles mode', (
        tester,
      ) async {
        _setTabletViewport(tester);

        await tester.pumpWidget(_host());
        await _tapCard(tester, 'Singles');

        expect(_getPage(tester).mode, MatchMode.singles);
      });

      testWidgets('tapping Doubles opens MatchSetupPage with doubles mode', (
        tester,
      ) async {
        _setTabletViewport(tester);

        await tester.pumpWidget(_host());
        await _tapCard(tester, 'Doubles');

        final page = tester.widget<MatchSetupPage>(find.byType(MatchSetupPage));
        expect(page.mode, MatchMode.doubles);
      });

      testWidgets(
        'tapping Three Players opens MatchSetupPage with threePlayer mode',
        (tester) async {
          _setTabletViewport(tester);

          await tester.pumpWidget(_host());
          await _tapCard(tester, 'Three Players');

          expect(_getPage(tester).mode, MatchMode.threePlayer);
        },
      );

      testWidgets('tapping Tournament does not navigate', (tester) async {
        await tester.pumpWidget(_host());
        await _tapCard(tester, 'Tournament');

        expect(find.byType(MatchSetupPage), findsNothing);
        expect(find.byType(HomePage), findsOneWidget);
      });
    });
  });
}
