import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/match_config_panel.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';

// ---------------------------------------------------------------------------

Visibility _breakFormatVisibility(WidgetTester tester) {
  return tester.widget<Visibility>(
    find.byKey(const ValueKey('break-format-visibility')),
  );
}

Visibility _inningsVisibility(WidgetTester tester) {
  return tester.widget<Visibility>(
    find.byKey(const ValueKey('innings-visibility')),
  );
}

void _setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pump(WidgetTester tester, MatchSetupNotifier notifier) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<MatchSetupNotifier>.value(
      value: notifier,
      child: const MaterialApp(home: Scaffold(body: MatchConfigPanel())),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  late MatchSetupNotifier notifier;

  setUp(() {
    notifier = MatchSetupNotifier(mode: MatchMode.singles);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('MatchConfigPanel — rendering', () {
    testWidgets('renders all four game-type segments', (tester) async {
      await _pump(tester, notifier);

      expect(find.text('8 Ball'), findsOneWidget);
      expect(find.text('9 Ball'), findsOneWidget);
      expect(find.text('10 Ball'), findsOneWidget);
      expect(find.text('14.1'), findsOneWidget);
    });

    testWidgets('renders break-format segments for non-straight-pool', (
      tester,
    ) async {
      await _pump(tester, notifier);

      expect(find.text('Winner Break'), findsOneWidget);
      expect(find.text('Alternate Break'), findsOneWidget);
    });

    testWidgets('renders the innings stepper for straight pool', (
      tester,
    ) async {
      notifier.gameType = GameType.straightPool;
      await _pump(tester, notifier);

      // The stepper's label is composed as '25 innings' for the default value.
      expect(find.text('25 innings'), findsOneWidget);
    });
  });

  group('MatchConfigPanel — visibility flags', () {
    testWidgets('break-format is visible for non-straight-pool', (
      tester,
    ) async {
      await _pump(tester, notifier);

      final visibility = _breakFormatVisibility(tester);
      expect(visibility.visible, isTrue);
    });

    testWidgets('break-format is hidden for straight pool', (tester) async {
      notifier.gameType = GameType.straightPool;
      await _pump(tester, notifier);

      final visibility = _breakFormatVisibility(tester);
      expect(visibility.visible, isFalse);
    });

    testWidgets('innings is hidden for non-straight-pool', (tester) async {
      await _pump(tester, notifier);

      final visibility = _inningsVisibility(tester);
      expect(visibility.visible, isFalse);
    });

    testWidgets('innings is visible for straight pool', (tester) async {
      notifier.gameType = GameType.straightPool;
      await _pump(tester, notifier);

      final visibility = _inningsVisibility(tester);
      expect(visibility.visible, isTrue);
    });
  });

  group('MatchConfigPanel — callback wiring', () {
    testWidgets('tapping 14.1 updates the notifier game type', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('14.1'));
      await tester.pump();

      expect(notifier.gameType, GameType.straightPool);
    });

    testWidgets('tapping Winner Break updates the notifier break format', (
      tester,
    ) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('Winner Break'));
      await tester.pump();

      expect(notifier.breakFormat, BreakFormat.winnerBreak);
    });
  });

  group('MatchConfigPanel — wide layout', () {
    testWidgets('above the wide breakpoint side-by-side', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.wide + 100);
      await _pump(tester, notifier);

      final gameType = tester.getTopLeft(
        find.byType(SegmentedButton<GameType>),
      );
      final raceTo = tester.getTopLeft(
        find.byType(NumberStepper).first,
      );

      // Same row: tops align; stepper sits to the right.
      expect(gameType.dy, raceTo.dy);
      expect(raceTo.dx, greaterThan(gameType.dx));
    });

    testWidgets('wide Visibility maintains hidden size', (tester) async {
      _setWidth(tester, LayoutBreakpoints.wide + 100);
      await _pump(tester, notifier);

      final visibility = _inningsVisibility(tester);
      expect(visibility.maintainSize, isTrue);
    });
  });

  group('MatchConfigPanel — narrow layout', () {
    testWidgets('below the wide breakpoint stacks vertically', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.wide - 100);
      await _pump(tester, notifier);

      final gameType = tester.getTopLeft(
        find.byType(SegmentedButton<GameType>),
      );
      final breakFormat = tester.getTopLeft(
        find.byType(SegmentedButton<BreakFormat>),
      );
      final raceTo = tester.getTopLeft(
        find.byType(NumberStepper).first,
      );

      expect(gameType.dx, breakFormat.dx);
      expect(breakFormat.dx, raceTo.dx);
      expect(breakFormat.dy, greaterThan(gameType.dy));
      expect(raceTo.dy, greaterThan(breakFormat.dy));
    });

    testWidgets('narrow Visibility does not maintain hidden size', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.wide - 100);
      await _pump(tester, notifier);

      final visibility = _inningsVisibility(tester);
      expect(visibility.maintainSize, isFalse);
    });
  });

  group('MatchConfigPanel — alignment', () {
    testWidgets('selector labels are centered within their segments', (
      tester,
    ) async {
      await _pump(tester, notifier);

      final label = find.text(GameType.tenBall.displayName);
      final labelRect = tester.getRect(label);
      final segmentRect = tester.getRect(
        find.ancestor(of: label, matching: find.byType(InkWell)).first,
      );

      expect(
        labelRect.center,
        offsetMoreOrLessEquals(segmentRect.center, epsilon: 0.5),
      );
    });
  });
}
