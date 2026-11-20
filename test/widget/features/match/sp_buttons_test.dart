import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/sp_scoring.dart';
import 'package:runout/features/match/widgets/sp_buttons.dart';
import 'package:runout/features/match/widgets/sp_scoring_dialog.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(WidgetTester tester, MatchNotifier notifier) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<MatchNotifier>.value(
      value: notifier,
      child: MaterialApp(
        home: Scaffold(
          body: Consumer<MatchNotifier>(
            builder: (context, notifier, _) {
              final scoring = SPScoring(notifier);
              return SPButtons(
                ballsRemaining: notifier.match.ballsRemaining,
                onEndInning: () => scoring.endInning(context),
                onOpenScoring: () => scoring.openScoringDialog(context),
                onNewRack: () => scoring.newRack(context, remaining: 1),
              );
            },
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  final match = makeStraightPoolMatch();
  late MatchNotifier notifier;

  setUp(() {
    notifier = MatchNotifier(match)..selectStartingSide(0);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('rendering', () {
    testWidgets('shows end inning, balls count, and new rack', (tester) async {
      await _pump(tester, notifier);

      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.byIcon(Icons.change_history_rounded), findsOneWidget);
    });

    testWidgets('balls count reflects match.ballsRemaining', (tester) async {
      notifier.scoreRemaining(10);
      await _pump(tester, notifier);

      expect(find.text('10'), findsOneWidget);
    });
  });

  group('end inning', () {
    testWidgets('tapping end inning advances the breaker', (tester) async {
      final before = notifier.match.currentSideIndex;
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
      await tester.pump();

      expect(notifier.match.currentSideIndex, isNot(before));
    });

    testWidgets('shows extension snackbar and resets the flag', (tester) async {
      notifier.endVisit();
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Tied — 5 more innings'), findsOneWidget);
      expect(notifier.notifyExtension, isFalse);
    });
  });

  group('score dialog', () {
    testWidgets('tapping balls opens the dialog', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(SPScoringDialog), findsOneWidget);
      expect(find.text('Record Inning'), findsOneWidget);
      expect(find.text('Player-0'), findsOneWidget);
      expect(find.text('How many balls left?'), findsOneWidget);
    });

    testWidgets('0 balls remaining starts a new rack', (tester) async {
      final local = MatchNotifier(makeStraightPoolMatch(raceTo: 20));
      addTearDown(local.dispose);
      local.selectStartingSide(0);
      await _pump(tester, local);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('0 ball remaining'));
      await tester.pumpAndSettle();

      expect(local.match.sides.first.score, 15);
      expect(local.match.ballsRemaining, 15);
      expect(local.match.currentSideIndex, 0);
    });

    testWidgets('1 ball remaining starts a new rack', (tester) async {
      final local = MatchNotifier(makeStraightPoolMatch(raceTo: 20));
      addTearDown(local.dispose);
      local.selectStartingSide(0);
      await _pump(tester, local);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1 ball remaining'));
      await tester.pumpAndSettle();

      expect(local.match.sides.first.score, 14);
      expect(local.match.ballsRemaining, 15);
      expect(local.match.currentSideIndex, 0);
    });

    testWidgets('tap next inning applies scoreRemaining', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(notifier.match.sides.first.score, 5);
      expect(notifier.match.ballsRemaining, 10);
    });

    testWidgets('selecting standard foul applies scoreRemaining', (
      tester,
    ) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(notifier.match.sides.first.score, -1);
    });

    testWidgets('selecting break foul with continue (default) '
        'applies scoreRemaining with keepsTurn false', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(notifier.match.sides.first.score, -2);
      expect(notifier.match.currentSideIndex, 1);
    });

    testWidgets('selecting break foul with re-break '
        'applies scoreRemaining with keepsTurn true', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      await tester.tap(find.text('Re-break'));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(notifier.match.sides.first.score, -2);
      expect(notifier.match.currentSideIndex, 0);
    });

    testWidgets('shows three-fouls snackbar and resets the flag', (
      tester,
    ) async {
      notifier
        ..scoreVisit(points: 0, foul: Foul.standard, keepsTurn: true)
        ..scoreVisit(points: 0, foul: Foul.standard, keepsTurn: true);

      await _pump(tester, notifier);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Foul'));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Third fouls'), findsOneWidget);
      expect(notifier.notifyThreeFouls, isFalse);
    });
  });

  group('new rack', () {
    testWidgets('calls newRack(1)', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.change_history_rounded));
      await tester.pump();

      expect(notifier.match.sides.first.score, 14);
      expect(notifier.match.currentSideIndex, 0);
    });
  });

  group('continue after target reached', () {
    testWidgets('shows the confirm dialog', (tester) async {
      notifier.newRack(1);
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.change_history_rounded));
      await tester.pump();

      expect(find.byType(ConfirmDialog), findsOneWidget);
      expect(find.text('Target reached.'), findsOneWidget);
      expect(notifier.askToContinue, isFalse);
    });

    testWidgets('Continue keeps the match playing', (tester) async {
      notifier.newRack(1);
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.change_history_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(notifier.match.status, MatchStatus.playing);
      expect(notifier.match.winnerIndex, isNull);
    });

    testWidgets('barrier tap keeps the prompt open', (tester) async {
      notifier.newRack(1);
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.change_history_rounded));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsOneWidget);
      expect(notifier.match.status, MatchStatus.playing);
    });

    testWidgets('End finishes the match with the breaker as winner', (
      tester,
    ) async {
      notifier.newRack(1);
      await _pump(tester, notifier);

      await tester.tap(find.byIcon(Icons.change_history_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle();

      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
    });
  });
}
