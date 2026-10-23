import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/features/match/widgets/ball_button.dart';
import 'package:runout/features/match/widgets/remaining_picker_dialog.dart';

// ---------------------------------------------------------------------------

Future<void> _openDialog(
  WidgetTester tester, {
  required ValueChanged<RemainingResult?> onResult,
  int remaining = 15,
  bool showBreakFoul = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: _Host(
        onResult: onResult,
        remaining: remaining,
        showBreakFoul: showBreakFoul,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

class _Host extends StatelessWidget {
  const new({
    required this.onResult,
    required this.remaining,
    required this.showBreakFoul,
  });

  final ValueChanged<RemainingResult?> onResult;
  final int remaining;
  final bool showBreakFoul;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await showDialog<RemainingResult>(
          context: context,
          builder: (_) => RemainingPickerDialog(
            remaining: remaining,
            showBreakFoul: showBreakFoul,
          ),
        );
        onResult(result);
      },
      child: const Text('open'),
    );
  }
}

BallButton _ball(WidgetTester tester, int value) {
  return tester.widget<BallButton>(
    find.widgetWithText(BallButton, '$value'),
  );
}

SegmentedButton<Foul> _foulSelector(WidgetTester tester) {
  return tester.widget<SegmentedButton<Foul>>(
    find.byType(SegmentedButton<Foul>),
  );
}

SegmentedButton<bool> _turnSelector(WidgetTester tester) {
  return tester.widget<SegmentedButton<bool>>(
    find.byType(SegmentedButton<bool>),
  );
}

Visibility _turnVisibility(WidgetTester tester) {
  return tester.widget<Visibility>(
    find.byKey(const ValueKey('turn-selector-visibility')),
  );
}

void _setViewport(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the title', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('How many balls left?'), findsOneWidget);
    });

    testWidgets('renders all 14 balls', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.byType(BallButton), findsNWidgets(14));
    });

    testWidgets('renders values 2..15 exactly once', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      for (var value = 2; value <= 15; value++) {
        expect(find.text('$value'), findsOneWidget);
      }
      expect(find.text('1'), findsNothing);
      expect(find.text('16'), findsNothing);
    });

    testWidgets('renders Cancel and Confirm', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });
  });

  group('ball button size', () {
    testWidgets('has width 48 on narrow layout', (tester) async {
      _setViewport(tester, 400, 600);
      await _openDialog(tester, onResult: (_) {});

      expect(_ball(tester, 2).width, 48);
    });

    testWidgets('has width 60 on wider layout', (tester) async {
      await _openDialog(tester, onResult: (_) {});

      expect(_ball(tester, 2).width, 60);
    });

    testWidgets('has padding of 2 on narrow layout', (tester) async {
      _setViewport(tester, 400, 600);
      await _openDialog(tester, onResult: (_) {});

      final balls = find.byType(BallButton);
      final a = tester.getRect(balls.at(11));
      final b = tester.getRect(balls.at(12));

      expect(b.left - a.right, 4);
    });

    testWidgets('has padding of 4 on wider layout', (tester) async {
      await _openDialog(tester, onResult: (_) {});

      final balls = find.byType(BallButton);
      final a = tester.getRect(balls.at(11));
      final b = tester.getRect(balls.at(12));

      expect(b.left - a.right, 8);
    });
  });

  group('ball selection', () {
    testWidgets('balls above remaining are disabled', (tester) async {
      await _openDialog(tester, remaining: 7, onResult: (_) {});
      for (var value = 2; value <= 7; value++) {
        expect(_ball(tester, value).onTap, isNotNull, reason: '$value');
      }
      for (var value = 8; value <= 15; value++) {
        expect(_ball(tester, value).onTap, isNull, reason: '$value');
      }
    });

    testWidgets('initial selected range is 2..remaining', (tester) async {
      await _openDialog(tester, remaining: 7, onResult: (_) {});
      for (var value = 2; value <= 7; value++) {
        expect(_ball(tester, value).selected, isTrue, reason: '$value');
      }
      for (var value = 8; value <= 15; value++) {
        expect(_ball(tester, value).selected, isFalse, reason: '$value');
      }
    });

    testWidgets('tapping a ball updates the selected range', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.widgetWithText(BallButton, '4'));
      await tester.pump();

      expect(_ball(tester, 2).selected, isTrue);
      expect(_ball(tester, 4).selected, isTrue);
      expect(_ball(tester, 5).selected, isFalse);
    });

    testWidgets('tapping a disabled ball does nothing', (tester) async {
      await _openDialog(tester, remaining: 7, onResult: (_) {});
      await tester.tap(
        find.widgetWithText(BallButton, '10'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(_ball(tester, 7).selected, isTrue);
      expect(_ball(tester, 8).selected, isFalse);
    });
  });

  group('foul selector', () {
    testWidgets('defaults to no foul', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(_foulSelector(tester).selected, {Foul.none});
    });

    testWidgets('breakFoul segment hidden when showBreakFoul is false', (
      tester,
    ) async {
      await _openDialog(
        tester,
        showBreakFoul: false,
        onResult: (_) {},
      );
      expect(find.text(Foul.breakFoul.displayName), findsNothing);
    });

    testWidgets('breakFoul segment shown when showBreakFoul is true', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text(Foul.breakFoul.displayName), findsOneWidget);
    });

    testWidgets('selecting standard updates the selection', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();
      expect(_foulSelector(tester).selected, {Foul.standard});
    });

    testWidgets('selecting breakFoul disables and unhighlights balls', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      expect(_foulSelector(tester).selected, {Foul.breakFoul});
      for (var value = 2; value <= 15; value++) {
        expect(_ball(tester, value).onTap, isNull, reason: '$value');
        expect(_ball(tester, value).selected, isFalse, reason: '$value');
      }
    });
  });

  group('turn selector', () {
    testWidgets('hidden when foul is none', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(_turnVisibility(tester).visible, isFalse);
    });

    testWidgets('shown when breakFoul is selected', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      expect(_turnVisibility(tester).visible, isTrue);
    });

    testWidgets('defaults to Continue', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      expect(_turnSelector(tester).selected, {false});
    });

    testWidgets('selecting Re-break updates the selection', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      expect(_turnSelector(tester).selected, {true});
    });

    testWidgets('leaving breakFoul for standard resets to Continue', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      expect(_turnSelector(tester).selected, {false});
    });

    testWidgets('leaving breakFoul for none resets to Continue', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      await tester.tap(find.text(Foul.none.displayName));
      await tester.pump();
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      expect(_turnSelector(tester).selected, {false});
    });
  });

  group('return value', () {
    testWidgets('Cancel pops null', (tester) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [null]);
    });

    testWidgets('Confirm with defaults returns remaining, none, no keep', (
      tester,
    ) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(
        results.first,
        (remaining: 15, keepsTurn: false, foul: Foul.none),
      );
    });

    testWidgets('Confirm after picking a ball returns the picked value', (
      tester,
    ) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.widgetWithText(BallButton, '9'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(results.first?.remaining, 9);
    });

    testWidgets('Confirm with standard foul returns keepsTurn false', (
      tester,
    ) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.standard);
      expect(results.single?.keepsTurn, isFalse);
    });

    testWidgets('Confirm with breakFoul + Continue returns keepsTurn false', (
      tester,
    ) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.breakFoul);
      expect(results.single?.keepsTurn, isFalse);
    });

    testWidgets('Confirm with breakFoul + Re-break returns keepsTurn true', (
      tester,
    ) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.breakFoul);
      expect(results.single?.keepsTurn, isTrue);
    });

    testWidgets(
      'Confirm after Re-break then standard returns keepsTurn false',
      (tester) async {
        final results = <RemainingResult?>[];
        await _openDialog(tester, onResult: results.add);

        await tester.tap(find.text(Foul.breakFoul.displayName));
        await tester.pump();
        await tester.tap(find.text('Re-break'));
        await tester.pump();
        await tester.tap(find.text(Foul.standard.displayName));
        await tester.pump();
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(results.single?.foul, Foul.standard);
        expect(results.single?.keepsTurn, isFalse);
      },
    );

    testWidgets('barrier dismiss pops null', (tester) async {
      final results = <RemainingResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(results, [null]);
    });
  });

  group('overflow', () {
    testWidgets('does not overflow at a short viewport', (tester) async {
      _setViewport(tester, 800, 400);
      await _openDialog(tester, onResult: (_) {});

      expect(tester.takeException(), isNull);
    });
  });
}
