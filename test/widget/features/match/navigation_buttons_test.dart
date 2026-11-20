import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/navigation_buttons.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onRestart,
  VoidCallback? onExit,
  double width = 1000,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NavigationButtons(
          onRestart: onRestart ?? () {},
          onExit: onExit ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('MatchNavigationButtons', () {
    testWidgets('fires the restart and exit callbacks', (tester) async {
      var restarts = 0;
      var exits = 0;
      await _pump(
        tester,
        width: 375,
        onRestart: () => restarts++,
        onExit: () => exits++,
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.tap(find.byIcon(Icons.home_rounded));

      expect(restarts, 1);
      expect(exits, 1);
    });

    testWidgets('has labels and no tooltips on wider width', (tester) async {
      await _pump(tester, width: 800);

      expect(find.text('Setup'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.byTooltip('Back to setup'), findsNothing);
      expect(find.byTooltip('Exit to home'), findsNothing);
    });

    testWidgets('has tooltips and no labels on compact width', (tester) async {
      await _pump(tester, width: 400);

      expect(find.text('Setup'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.byTooltip('Back to setup'), findsOneWidget);
      expect(find.byTooltip('Exit to home'), findsOneWidget);
    });
  });
}
