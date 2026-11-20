import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/sp_buttons.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester,
  MatchNotifier notifier, {
  double width = 1000,
  VoidCallback? onRestart,
  VoidCallback? onExit,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<MatchNotifier>.value(
      value: notifier,
      child: MaterialApp(
        home: Scaffold(
          body: ControlsBar(
            onRestart: onRestart ?? () {},
            onExit: onExit ?? () {},
          ),
        ),
      ),
    ),
  );
}

TextButton _button(WidgetTester tester, IconData icon) {
  return tester.widget<TextButton>(
    find.widgetWithIcon(TextButton, icon),
  );
}

// ---------------------------------------------------------------------------

void main() {
  late MatchNotifier notifier;

  setUp(() {
    notifier = MatchNotifier(makeMatch());
  });

  tearDown(() {
    notifier.dispose();
  });

  group('undo redo buttons', () {
    testWidgets('disabled on a fresh match', (tester) async {
      await _pump(tester, notifier);

      expect(_button(tester, Icons.undo_rounded).onPressed, isNull);
      expect(_button(tester, Icons.redo_rounded).onPressed, isNull);
    });

    testWidgets('enable from match history', (tester) async {
      await _pump(tester, notifier);

      notifier.selectStartingSide(0);
      await tester.pump();

      expect(_button(tester, Icons.undo_rounded).onPressed, isNotNull);
      expect(_button(tester, Icons.redo_rounded).onPressed, isNull);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pump();

      expect(_button(tester, Icons.redo_rounded).onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.redo_rounded));
      await tester.pump();

      expect(_button(tester, Icons.undo_rounded).onPressed, isNotNull);
    });

    testWidgets('has label and no tooltip on wider width', (tester) async {
      await _pump(tester, notifier, width: 800);

      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Redo'), findsOneWidget);
      expect(find.byTooltip('Undo'), findsNothing);
      expect(find.byTooltip('Redo'), findsNothing);
    });

    testWidgets('has tooltip and no label on compact width', (tester) async {
      await _pump(tester, notifier, width: 400);

      expect(find.text('Undo'), findsNothing);
      expect(find.text('Redo'), findsNothing);
      expect(find.byTooltip('Undo'), findsOneWidget);
      expect(find.byTooltip('Redo'), findsOneWidget);
    });
  });

  group('navigation buttons', () {
    testWidgets('has label and no tooltip on wider width', (tester) async {
      await _pump(tester, notifier, width: 800);

      expect(find.text('Setup'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.byTooltip('Back to setup'), findsNothing);
      expect(find.byTooltip('Exit to home'), findsNothing);
    });

    testWidgets('has tooltip and no label on compact width', (tester) async {
      await _pump(tester, notifier, width: 400);

      expect(find.text('Setup'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(find.byTooltip('Back to setup'), findsOneWidget);
      expect(find.byTooltip('Exit to home'), findsOneWidget);
    });

    testWidgets('fire their callbacks', (tester) async {
      var restarts = 0;
      var exits = 0;

      await _pump(
        tester,
        notifier,
        width: 375,
        onRestart: () => restarts++,
        onExit: () => exits++,
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pump();

      expect(restarts, 1);
      expect(exits, 1);
    });
  });

  group('straight pool action', () {
    testWidgets('not present for non-straight-pool match', (tester) async {
      await _pump(tester, notifier);

      expect(find.byType(SPButtons), findsNothing);
    });

    testWidgets('present for straight-pool match', (tester) async {
      final match = makeStraightPoolMatch();
      final notifier = MatchNotifier(match);
      await _pump(tester, notifier);

      expect(find.byType(SPButtons), findsOneWidget);
    });

    testWidgets('not present when below the wide breakpoint', (tester) async {
      final match = makeStraightPoolMatch();
      final notifier = MatchNotifier(match);
      await _pump(tester, notifier, width: LayoutBreakpoints.wide - 100);

      expect(find.byType(SPButtons), findsNothing);
    });
  });
}
