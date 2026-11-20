import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/navigation_buttons.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onDiscard,
  VoidCallback? onEdit,
  VoidCallback? onExit,
  bool showEdit = true,
  double width = 1000,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NavigationButtons(
          onDiscard: onDiscard ?? () {},
          onEdit: showEdit ? (onEdit ?? () {}) : null,
          onExit: onExit ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('NavigationButtons', () {
    testWidgets('fires the discard, edit and exit callbacks', (tester) async {
      var discards = 0;
      var edits = 0;
      var exits = 0;
      await _pump(
        tester,
        width: 375,
        onDiscard: () => discards++,
        onEdit: () => edits++,
        onExit: () => exits++,
      );

      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.tap(find.byIcon(Icons.home_rounded));

      expect(discards, 1);
      expect(edits, 1);
      expect(exits, 1);
    });

    testWidgets('omits setup when editing is unavailable', (tester) async {
      await _pump(tester, width: 800, showEdit: false);

      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('has labels and no tooltips on wider width', (tester) async {
      await _pump(tester, width: 800);

      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Setup'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.byTooltip('Discard match'), findsNothing);
      expect(find.byTooltip('Back to setup'), findsNothing);
      expect(find.byTooltip('Exit to home'), findsNothing);
    });

    testWidgets('has tooltips and no labels on compact width', (tester) async {
      await _pump(tester, width: 400);

      expect(find.text('Discard'), findsNothing);
      expect(find.text('Setup'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.byTooltip('Discard match'), findsOneWidget);
      expect(find.byTooltip('Back to setup'), findsOneWidget);
      expect(find.byTooltip('Exit to home'), findsOneWidget);
    });

    testWidgets('uses the error color for discard', (tester) async {
      await _pump(tester);

      final button = tester.widget<TextButton>(
        find.widgetWithIcon(TextButton, Icons.delete_rounded),
      );
      final context = tester.element(find.byType(NavigationButtons));
      expect(
        button.style?.foregroundColor?.resolve({}),
        Theme.of(context).colorScheme.error,
      );
    });
  });
}
