import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/features/match/widgets/ball_button.dart';
import 'package:runout/features/match/widgets/sp_scoring_dialog.dart';
import 'package:runout/shared/widgets/choice_button.dart';

// ---------------------------------------------------------------------------

Future<void> _openDialog(
  WidgetTester tester, {
  required ValueChanged<SPScoreResult?> onResult,
  int remaining = 15,
  bool showBreakFoul = true,
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

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

  final ValueChanged<SPScoreResult?> onResult;
  final int remaining;
  final bool showBreakFoul;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await showDialog<SPScoreResult>(
          context: context,
          builder: (_) => SPScoringDialog(
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

ChoiceButton _button(WidgetTester tester, String label) {
  return tester.widget<ChoiceButton>(
    find.widgetWithText(ChoiceButton, label),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('header', () {
    testWidgets('renders the title', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('Record Inning'), findsOneWidget);
      expect(find.text('How many balls left?'), findsOneWidget);
    });
  });

  group('ball buttons', () {
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

  group('info', () {
    testWidgets('default', (tester) async {
      await _openDialog(tester, onResult: (_) {});

      expect(find.text('15 balls remaining'), findsOneWidget);
      expect(find.text('0 points'), findsOneWidget);
    });

    testWidgets('show remaining balls and points made', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.widgetWithText(BallButton, '10'));
      await tester.pump();

      expect(find.text('10 balls remaining'), findsOneWidget);
      expect(find.text('+5 points'), findsOneWidget);
    });

    testWidgets('show minus points made', (tester) async {
      await _openDialog(tester, onResult: (_) {});

      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();

      expect(find.text('-1 points'), findsOneWidget);

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      expect(find.text('-2 points'), findsOneWidget);
    });

    testWidgets('calculate points + foul correctly', (tester) async {
      await _openDialog(tester, onResult: (_) {});

      await tester.tap(find.widgetWithText(BallButton, '10'));
      await tester.pump();
      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();

      expect(find.text('+4 points'), findsOneWidget);
    });
  });

  group('foul selector', () {
    testWidgets('defaults to no foul', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(_button(tester, Foul.none.displayName).selected, isTrue);
    });

    testWidgets('breakFoul button hidden when showBreakFoul is false', (
      tester,
    ) async {
      await _openDialog(
        tester,
        showBreakFoul: false,
        onResult: (_) {},
      );
      expect(find.text(Foul.breakFoul.displayName), findsNothing);
    });

    testWidgets('breakFoul button shown when showBreakFoul is true', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text(Foul.breakFoul.displayName), findsOneWidget);
    });

    testWidgets('selecting standard updates the selection', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();

      expect(_button(tester, Foul.standard.displayName).selected, isTrue);
    });

    testWidgets('selecting breakFoul disables and unhighlights balls', (
      tester,
    ) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      expect(_button(tester, Foul.breakFoul.displayName).selected, isTrue);

      for (var value = 2; value <= 15; value++) {
        expect(_ball(tester, value).onTap, isNull, reason: '$value');
        expect(_ball(tester, value).selected, isFalse, reason: '$value');
      }
    });
  });

  group('turn selector', () {
    testWidgets('hidden when foul is none', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('Re-break'), findsNothing);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('shown when breakFoul is selected', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      expect(find.text('Re-break'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('defaults to Continue', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      expect(_button(tester, 'Continue').selected, isTrue);
    });

    testWidgets('selecting Re-break updates the selection', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      expect(_button(tester, 'Re-break').selected, isTrue);
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

      expect(_button(tester, 'Continue').selected, isTrue);
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

      expect(_button(tester, 'Continue').selected, isTrue);
    });
  });

  group('next inning', () {
    testWidgets('defaults returns remaining, none, no keep', (
      tester,
    ) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(
        results.first,
        (remaining: 15, keepsTurn: false, foul: Foul.none),
      );
    });

    testWidgets('after picking a ball returns the picked value', (
      tester,
    ) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.widgetWithText(BallButton, '9'));
      await tester.pump();
      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(results.first?.remaining, 9);
    });

    testWidgets('standard foul returns keepsTurn false', (
      tester,
    ) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();
      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.standard);
      expect(results.single?.keepsTurn, isFalse);
    });

    testWidgets('breakFoul + Continue returns keepsTurn false', (
      tester,
    ) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.breakFoul);
      expect(results.single?.keepsTurn, isFalse);
    });

    testWidgets('breakFoul + Re-break returns keepsTurn true', (
      tester,
    ) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();
      await tester.tap(find.text('Re-break'));
      await tester.pump();
      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(results.single?.foul, Foul.breakFoul);
      expect(results.single?.keepsTurn, isTrue);
    });

    testWidgets(
      'after Re-break then standard returns keepsTurn false',
      (tester) async {
        final results = <SPScoreResult?>[];
        await _openDialog(tester, onResult: results.add);

        await tester.tap(find.text(Foul.breakFoul.displayName));
        await tester.pump();
        await tester.tap(find.text('Re-break'));
        await tester.pump();
        await tester.tap(find.text(Foul.standard.displayName));
        await tester.pump();
        await tester.tap(find.text('Next Inning'));
        await tester.pumpAndSettle();

        expect(results.single?.foul, Foul.standard);
        expect(results.single?.keepsTurn, isFalse);
      },
    );
  });

  group('new rack', () {
    testWidgets('0 ball remaining', (tester) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text('0 ball remaining'));
      await tester.pumpAndSettle();

      expect(results.single?.remaining, 0);
      expect(results.single?.foul, Foul.none);
      expect(results.single?.keepsTurn, isTrue);
    });

    testWidgets('1 ball remaining', (tester) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.text('1 ball remaining'));
      await tester.pumpAndSettle();

      expect(results.single?.remaining, 1);
      expect(results.single?.foul, Foul.none);
      expect(results.single?.keepsTurn, isTrue);
    });
  });

  group('dynamic', () {
    testWidgets('barrier dismiss pops null', (tester) async {
      final results = <SPScoreResult?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(results, [null]);
    });

    testWidgets('does not overflow at 375 width and 2x text scale', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _openDialog(tester, onResult: (_) {}, width: 375);

      expect(tester.takeException(), isNull);
    });
  });
}
