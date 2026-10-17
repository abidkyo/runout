import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/features/match_setup/widgets/match_config_panel.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';
import 'package:runout/features/match_setup/widgets/player_slot.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';

// ---------------------------------------------------------------------------

// This is verbose. Can't improve for now.
const p1 = 'Joshua Filler';
const p2 = 'Shane Van Boening';

/// MatchConfigPanel in MatchSetupPage requires ~960px width; the default
/// 800×600 test surface is too narrow. Use a landscape tablet viewport.
void _setTabletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpSetupPage(WidgetTester tester, MatchMode mode) async {
  _setTabletViewport(tester);

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
  _setTabletViewport(tester);

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

    testWidgets('renders two player slots for singles', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(find.byType(PlayerSlot), findsNWidgets(2));
    });

    testWidgets('renders four player slots for doubles', (tester) async {
      await _pumpSetupPage(tester, MatchMode.doubles);

      expect(find.byType(PlayerSlot), findsNWidgets(4));
    });

    testWidgets(
      'renders three player slots for three-player',
      (tester) async {
        await _pumpSetupPage(tester, MatchMode.threePlayer);

        expect(find.byType(PlayerSlot), findsNWidgets(3));
      },
    );

    testWidgets('renders the config panel and actions', (tester) async {
      await _pumpSetupPage(tester, MatchMode.singles);

      expect(find.byType(MatchConfigPanel), findsOneWidget);
      expect(find.byType(SetupActions), findsOneWidget);
    });
  });

  group('player selection', () {
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
