import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/features/match_setup/widgets/match_config_panel.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';
import 'package:runout/features/match_setup/widgets/player_slot.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';

// ---------------------------------------------------------------------------

// This is verbose. Can't improve for now.
const p1 = 'Joshua Filler';
const p2 = 'Shane Van Boening';

Future<void> _pumpSetupPage(WidgetTester tester, MatchMode mode) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MatchSetupPage(mode: mode),
    ),
  );
}

Future<void> _pumpStackedSetupPage(
  WidgetTester tester,
  MatchMode mode,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MatchSetupPage(mode: mode),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _pickPlayer(WidgetTester tester, int index, String name) async {
  await tester.tap(find.byType(PlayerSlot).at(index));
  await tester.pumpAndSettle();

  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the singles app bar title', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(
        find.textContaining(MatchMode.singles.displayName),
        findsOneWidget,
      );
    });

    testWidgets('renders the doubles app bar title', (tester) async {
      await _pumpSetupPage(tester, MatchMode.doubles);

      expect(
        find.textContaining(MatchMode.doubles.displayName),
        findsOneWidget,
      );
    });

    testWidgets('renders the three-player app bar title', (tester) async {
      await _pumpSetupPage(tester, MatchMode.threePlayer);

      expect(
        find.textContaining(MatchMode.threePlayer.displayName),
        findsOneWidget,
      );
    });

    testWidgets('renders the config panel and actions', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(find.byType(MatchConfigPanel), findsOneWidget);
      expect(find.byType(SetupActions), findsOneWidget);
    });

    testWidgets('setup actions are pinned outside the scroll view', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(SetupActions),
        ),
        findsNothing,
      );
      expect(find.byType(SetupActions), findsOneWidget);
    });

    testWidgets('player panel and config panel are inside the scroll view', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(PlayerPanel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(MatchConfigPanel),
        ),
        findsOneWidget,
      );
    });
  });

  group('player selection', () {
    testWidgets('tapping a slot opens the picker for that side', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      await _pickPlayer(tester, 1, p2);

      final slots = tester
          .widgetList<PlayerSlot>(find.byType(PlayerSlot))
          .toList();
      expect(slots[0].player, isNull);
      expect(slots[1].player?.fullName, p2);
    });

    testWidgets('tapping a slot opens the player picker', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      await tester.tap(find.byType(PlayerSlot).first);
      await tester.pumpAndSettle();

      expect(find.byType(PlayerPickerDialog), findsOneWidget);
    });

    testWidgets('picking a player fills the slot', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);
      await _pickPlayer(tester, 0, p1);

      expect(find.byType(PlayerPickerDialog), findsNothing);
      expect(find.text(p1), findsOneWidget);
    });

    testWidgets('cancelling the picker leaves the slot empty', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      await tester.tap(find.byType(PlayerSlot).first);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(PlayerPickerDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayerPickerDialog), findsNothing);

      final slots = tester.widgetList<PlayerSlot>(find.byType(PlayerSlot));
      for (final slot in slots) {
        expect(slot.player, isNull);
      }
    });
  });

  group('start', () {
    testWidgets('shows a snackbar and does not navigate when empty', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(MatchPage), findsNothing);
    });

    testWidgets('shows a snackbar when only one side is filled', (
      tester,
    ) async {
      await _pumpSetupPage(tester, MatchMode.singles);
      await _pickPlayer(tester, 0, p1);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(MatchPage), findsNothing);
    });

    testWidgets('navigate to match page when both side filled', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);
      await _pickPlayer(tester, 0, p1);
      await _pickPlayer(tester, 1, p2);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsOneWidget);
      expect(find.byType(MatchSetupPage), findsNothing);
    });
  });

  group('cancel', () {
    testWidgets('pops the setup page', (tester) async {
      await _pumpStackedSetupPage(tester, MatchMode.singles);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchSetupPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}
