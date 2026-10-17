import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/straight_pool_actions.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester,
  MatchNotifier notifier, {
  VoidCallback? onRestart,
  VoidCallback? onExit,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<MatchNotifier>.value(
      value: notifier,
      child: MaterialApp(
        home: ControlsBar(
          onRestart: onRestart ?? () {},
          onExit: onExit ?? () {},
        ),
      ),
    ),
  );
}

IconButton _icon(WidgetTester tester, IconData icon) {
  return tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, icon),
  );
}

Visibility _actionsVisibility(WidgetTester tester) {
  return tester.widget<Visibility>(
    find.byKey(const ValueKey('straight-pool-actions-visibility')),
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

  group('undo and redo enablement', () {
    testWidgets('undo disabled on a fresh match', (tester) async {
      await _pump(tester, notifier);
      expect(_icon(tester, Icons.undo).onPressed, isNull);
    });

    testWidgets('redo disabled on a fresh match', (tester) async {
      await _pump(tester, notifier);
      expect(_icon(tester, Icons.redo).onPressed, isNull);
    });

    testWidgets('undo enabled after selectBreaker', (tester) async {
      await _pump(tester, notifier);
      notifier.selectBreaker(0);
      await tester.pump();

      expect(_icon(tester, Icons.undo).onPressed, isNotNull);
    });

    testWidgets('redo enabled after undo', (tester) async {
      await _pump(tester, notifier);
      notifier
        ..selectBreaker(0)
        ..undo();
      await tester.pump();

      expect(_icon(tester, Icons.redo).onPressed, isNotNull);
    });

    testWidgets('tapping undo enables redo', (tester) async {
      await _pump(tester, notifier);
      notifier.selectBreaker(0);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();

      expect(_icon(tester, Icons.redo).onPressed, isNotNull);
    });

    testWidgets('tapping redo re-enables undo', (tester) async {
      await _pump(tester, notifier);
      notifier
        ..selectBreaker(0)
        ..undo();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.redo));
      await tester.pump();

      expect(_icon(tester, Icons.undo).onPressed, isNotNull);
    });
  });

  group('restart and exit', () {
    testWidgets('restart fires onRestart once', (tester) async {
      var calls = 0;
      await _pump(tester, notifier, onRestart: () => calls++);

      await tester.tap(find.byIcon(Icons.replay));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('exit fires onExit once', (tester) async {
      var calls = 0;
      await _pump(tester, notifier, onExit: () => calls++);

      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pump();

      expect(calls, 1);
    });
  });

  group('straight-pool center slot', () {
    testWidgets('absent for 8-ball', (tester) async {
      await _pump(tester, notifier);
      expect(find.byType(StraightPoolActions), findsNothing);
    });

    testWidgets('present for straight pool', (tester) async {
      notifier = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 1, raceTo: 10),
      );
      await _pump(tester, notifier);
      expect(find.byType(StraightPoolActions), findsOneWidget);
    });

    testWidgets('hidden when straight pool is not playing', (tester) async {
      notifier = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 1, raceTo: 10),
      );
      await _pump(tester, notifier);

      expect(_actionsVisibility(tester).visible, isFalse);
    });

    testWidgets('visible when straight pool is playing', (tester) async {
      notifier = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 1, raceTo: 10),
      )..selectBreaker(0);
      await _pump(tester, notifier);

      expect(_actionsVisibility(tester).visible, isTrue);
    });

    testWidgets('hidden when straight pool is finished', (tester) async {
      notifier =
          MatchNotifier(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10))
            ..selectBreaker(0)
            ..scoreRemaining(2);
      await _pump(tester, notifier);

      expect(_actionsVisibility(tester).visible, isFalse);
    });
  });

  group('icon styling', () {
    testWidgets('all icons use the shared icon size', (tester) async {
      notifier = MatchNotifier(
        makeStraightPoolMatch(inningsLimit: 1, raceTo: 10),
      );
      await _pump(tester, notifier);

      expect(_icon(tester, Icons.undo).iconSize, 28);
      expect(_icon(tester, Icons.redo).iconSize, 28);
      expect(_icon(tester, Icons.replay).iconSize, 28);
      expect(_icon(tester, Icons.exit_to_app).iconSize, 28);
    });

    testWidgets('tooltips are set', (tester) async {
      await _pump(tester, notifier);

      expect(find.byTooltip('Undo'), findsOneWidget);
      expect(find.byTooltip('Redo'), findsOneWidget);
      expect(find.byTooltip('Back to setup'), findsOneWidget);
      expect(find.byTooltip('Exit to home'), findsOneWidget);
    });

    testWidgets('undo and redo use transparent disabled color', (tester) async {
      await _pump(tester, notifier);

      expect(_icon(tester, Icons.undo).disabledColor, Colors.transparent);
      expect(_icon(tester, Icons.redo).disabledColor, Colors.transparent);
    });
  });
}
