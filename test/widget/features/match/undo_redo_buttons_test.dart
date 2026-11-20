import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/undo_redo_buttons.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  bool canUndo = false,
  bool canRedo = false,
  VoidCallback? onUndo,
  VoidCallback? onRedo,
  double width = 1000,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UndoRedoButtons(
          canUndo: canUndo,
          canRedo: canRedo,
          onUndo: onUndo ?? () {},
          onRedo: onRedo ?? () {},
        ),
      ),
    ),
  );
}

IconButton _button(WidgetTester tester, IconData icon) {
  return tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, icon),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('UndoRedoButtons', () {
    testWidgets('disables both buttons when there is no history', (
      tester,
    ) async {
      await _pump(tester);

      expect(_button(tester, Icons.undo_rounded).onPressed, isNull);
      expect(_button(tester, Icons.redo_rounded).onPressed, isNull);
    });

    testWidgets('enables buttons from the passed flags', (tester) async {
      await _pump(tester, canUndo: true, canRedo: true);

      expect(_button(tester, Icons.undo_rounded).onPressed, isNotNull);
      expect(_button(tester, Icons.redo_rounded).onPressed, isNotNull);
    });

    testWidgets('calls the matching callback', (tester) async {
      var undos = 0;
      var redos = 0;
      await _pump(
        tester,
        canUndo: true,
        canRedo: true,
        onUndo: () => undos++,
        onRedo: () => redos++,
      );

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.tap(find.byIcon(Icons.redo_rounded));

      expect(undos, 1);
      expect(redos, 1);
    });

    testWidgets('has labels and tooltips on wider width', (tester) async {
      await _pump(tester, width: 800);

      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Redo'), findsOneWidget);
      expect(find.byTooltip('Undo'), findsOneWidget);
      expect(find.byTooltip('Redo'), findsOneWidget);
    });

    testWidgets('has tooltips and no labels on compact width', (tester) async {
      await _pump(tester, width: 400);

      expect(find.text('Undo'), findsNothing);
      expect(find.text('Redo'), findsNothing);
      expect(find.byTooltip('Undo'), findsOneWidget);
      expect(find.byTooltip('Redo'), findsOneWidget);
    });
  });
}
