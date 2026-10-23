import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/foul.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/new_rack_picker_dialog.dart';
import 'package:runout/features/match/widgets/remaining_picker_dialog.dart';
import 'package:runout/features/match/widgets/straight_pool_actions.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

Widget _host(MatchNotifier notifier) {
  return ChangeNotifierProvider<MatchNotifier>.value(
    value: notifier,
    child: const MaterialApp(
      home: Scaffold(body: StraightPoolActions()),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  final match = makeStraightPoolMatch();
  late MatchNotifier notifier;

  setUp(() {
    notifier = MatchNotifier(match)..selectBreaker(0);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('StraightPoolActions — rendering', () {
    testWidgets('shows end visit, remaining count, and new rack', (
      tester,
    ) async {
      await tester.pumpWidget(_host(notifier));

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.byIcon(Icons.change_history), findsOneWidget);
    });

    testWidgets('remaining count reflects match.remaining', (tester) async {
      notifier.scoreRemaining(10);
      await tester.pumpWidget(_host(notifier));

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('remaining count has a tooltip', (tester) async {
      await tester.pumpWidget(_host(notifier));

      expect(find.byTooltip('Balls remaining'), findsOneWidget);
    });
  });

  group('StraightPoolActions — end visit', () {
    testWidgets('tapping end visit advances the breaker', (tester) async {
      final before = notifier.match.currentBreakerIndex;
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pump();

      expect(notifier.match.currentBreakerIndex, isNot(before));
    });

    testWidgets('shows extension snackbar and resets the flag', (tester) async {
      notifier.endVisit();
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Tied — 5 more innings'), findsOneWidget);
      expect(notifier.notifyExtension, isFalse);
    });
  });

  group('StraightPoolActions — remaining picker', () {
    testWidgets('tapping remaining opens the dialog', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(RemainingPickerDialog), findsOneWidget);
      expect(find.text('How many balls left?'), findsOneWidget);
    });

    testWidgets('confirming a value applies scoreRemaining', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, 5);
      expect(notifier.match.remaining, 10);
    });

    testWidgets('selecting standard foul applies scoreRemaining', (
      tester,
    ) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.standard.displayName));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, -1);
    });

    testWidgets('selecting break foul with continue (default) '
        'applies scoreRemaining with keepsTurn false', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, -2);
      expect(notifier.match.currentBreakerIndex, 1);
    });

    testWidgets('selecting break foul with re-break '
        'applies scoreRemaining with keepsTurn true', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Foul.breakFoul.displayName));
      await tester.pump();

      await tester.tap(find.text('Re-break'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, -2);
      expect(notifier.match.currentBreakerIndex, 0);
    });

    testWidgets('cancelling does not change the match', (tester) async {
      final before = notifier.match.scores.first;
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, before);
      expect(notifier.match.remaining, 15);
    });

    testWidgets('shows three-fouls snackbar and resets the flag', (
      tester,
    ) async {
      notifier
        ..incrementScore(0, points: 0, foul: Foul.standard, keepsTurn: true)
        ..incrementScore(0, points: 0, foul: Foul.standard, keepsTurn: true);

      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Foul'));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Third fouls'), findsOneWidget);
      expect(notifier.notifyThreeFouls, isFalse);
    });
  });

  group('StraightPoolActions — new rack', () {
    testWidgets('short press calls newRack(1)', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pump();

      expect(notifier.match.scores.first, 14);
      expect(notifier.match.currentBreakerIndex, 0);
    });

    testWidgets('long press opens the new rack picker', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.longPress(find.byIcon(Icons.change_history));
      await tester.pumpAndSettle();

      expect(find.byType(NewRackPickerDialog), findsOneWidget);
      expect(find.text('How many balls left?'), findsOneWidget);
    });

    testWidgets('long press then selecting 0 add 15 points', (
      tester,
    ) async {
      await tester.pumpWidget(_host(notifier));

      await tester.longPress(find.byIcon(Icons.change_history));
      await tester.pumpAndSettle();

      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, 15);
      expect(notifier.match.currentBreakerIndex, 0);
    });

    testWidgets('long press then selecting 1 add 14 points', (
      tester,
    ) async {
      await tester.pumpWidget(_host(notifier));

      await tester.longPress(find.byIcon(Icons.change_history));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(notifier.match.scores.first, 14);
      expect(notifier.match.currentBreakerIndex, 0);
    });
  });

  group('StraightPoolActions — continue after target', () {
    testWidgets('short press at the target shows the confirm dialog', (
      tester,
    ) async {
      notifier.newRack(1);
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pump();

      expect(find.byType(ConfirmDialog), findsOneWidget);
      expect(find.text('Target reached.'), findsOneWidget);
      expect(notifier.askToContinue, isFalse);
    });

    testWidgets('Continue keeps the match playing', (tester) async {
      notifier.newRack(1);
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(notifier.match.status, MatchStatus.playing);
      expect(notifier.match.winnerIndex, isNull);
    });

    testWidgets('End finishes the match with the breaker as winner', (
      tester,
    ) async {
      notifier.newRack(1);
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.byIcon(Icons.change_history));
      await tester.pumpAndSettle();

      await tester.tap(find.text('End'));
      await tester.pumpAndSettle();

      expect(notifier.match.status, MatchStatus.finished);
      expect(notifier.match.winnerIndex, 0);
    });
  });
}
