import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/app.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/constants/match_defaults.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/features/match_setup/widgets/break_format_selector.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';
import 'package:runout/features/match_setup/widgets/game_type_selector.dart';
import 'package:runout/features/match_setup/widgets/mode_selector.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';

// ---------------------------------------------------------------------------

// This is verbose. Can't improve for now.
const p1 = 'Joshua Filler';
const p2 = 'Shane Van Boening';

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _pumpSetupPage(
  WidgetTester tester, {
  Size size = const Size(800, 1200),
}) async {
  _setSize(tester, size);
  await tester.pumpWidget(
    const AppProviders(
      child: MaterialApp(
        home: MatchSetupPage(),
      ),
    ),
  );
}

Future<void> _pumpStackedSetupPage(WidgetTester tester) async {
  _setSize(tester, const Size(800, 1200));
  await tester.pumpWidget(
    AppProviders(
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MatchSetupPage(),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _slot(int sideIndex, int slotIndex) {
  return find.byKey(
    ValueKey('player-slot-$sideIndex-$slotIndex'),
  );
}

Finder _allSlots() {
  return find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('player-slot-'),
  );
}

Future<void> _pickPlayer(
  WidgetTester tester,
  int sideIndex,
  int slotIndex,
  String name,
) async {
  await tester.tap(_slot(sideIndex, slotIndex));
  await tester.pumpAndSettle();

  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the in-page header without an app bar', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      expect(find.text('New Match'), findsOneWidget);
      expect(
        find.text('Set up your match details below.'),
        findsOneWidget,
      );
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('renders all setup sections and actions', (tester) async {
      await _pumpSetupPage(tester);

      expect(find.byType(ModeSelector), findsOneWidget);
      expect(find.byType(PlayerPanel), findsOneWidget);
      expect(find.byType(GameTypeSelector), findsOneWidget);
      expect(find.byType(BreakFormatSelector), findsOneWidget);
      expect(find.byType(NumberStepper), findsOneWidget);
      expect(find.byType(SetupActions), findsOneWidget);
      expect(find.text('Match Mode'), findsOneWidget);
      expect(find.text('Players'), findsOneWidget);
      expect(find.text('Game Type'), findsOneWidget);
      expect(find.text('Break Format'), findsOneWidget);
      expect(find.text('Race to'), findsOneWidget);
    });

    testWidgets('setup actions are pinned outside the scroll view', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(SetupActions),
        ),
        findsNothing,
      );
      expect(find.byType(SetupActions), findsOneWidget);
    });

    testWidgets('sections are inside the scroll view', (tester) async {
      await _pumpSetupPage(tester);

      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(ModeSelector),
        ),
        findsOneWidget,
      );
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
          matching: find.byType(GameTypeSelector),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(BreakFormatSelector),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(NumberStepper),
        ),
        findsOneWidget,
      );
    });
  });

  group('match mode', () {
    testWidgets('defaults to singles', (tester) async {
      await _pumpSetupPage(tester);

      expect(_allSlots(), findsNWidgets(2));
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);

      final singles = tester.widget<ChoiceButton>(
        find.widgetWithText(ChoiceButton, MatchMode.singles.displayName),
      );
      expect(singles.selected, isTrue);
    });

    testWidgets('switching modes updates the player slots', (tester) async {
      await _pumpSetupPage(tester);

      await tester.tap(find.text(MatchMode.doubles.displayName));
      await tester.pump();

      expect(_allSlots(), findsNWidgets(4));
      expect(find.text('Team A'), findsOneWidget);
      expect(find.text('Team B'), findsOneWidget);

      await tester.tap(find.text(MatchMode.threePlayer.displayName));
      await tester.pump();

      expect(_allSlots(), findsNWidgets(3));
      expect(find.text('Player 3'), findsOneWidget);

      await tester.tap(find.text(MatchMode.singles.displayName));
      await tester.pump();

      expect(_allSlots(), findsNWidgets(2));
    });
  });

  group('config', () {
    testWidgets('default hides innings and shows break format', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      expect(find.byType(BreakFormatSelector), findsOneWidget);
      expect(find.byType(NumberStepper), findsOneWidget);
      expect(find.text('Race to'), findsOneWidget);
      expect(find.text('Innings'), findsNothing);
    });

    testWidgets('straight pool shows innings and hides break format', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      await tester.tap(find.text(GameType.straightPool.displayName));
      await tester.pump();

      expect(find.byType(BreakFormatSelector), findsNothing);
      expect(find.byType(NumberStepper), findsNWidgets(2));
      expect(find.text('Race to'), findsOneWidget);
      expect(find.text('Innings'), findsOneWidget);
      expect(
        find.text(MatchDefaults.straightPoolRaceTo.toString()),
        findsOneWidget,
      );
      expect(find.text(MatchDefaults.inningsLimit.toString()), findsOneWidget);
    });

    testWidgets('switching back from straight pool restores rotation', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      await tester.tap(find.text(GameType.straightPool.displayName));
      await tester.pump();
      await tester.tap(find.text(GameType.eightBall.displayName));
      await tester.pump();

      expect(find.byType(BreakFormatSelector), findsOneWidget);
      expect(find.byType(NumberStepper), findsOneWidget);
      expect(find.text('Race to'), findsOneWidget);
      expect(find.text(MatchDefaults.raceTo.toString()), findsOneWidget);
    });
  });

  group('player selection', () {
    testWidgets('tapping a slot opens the picker for that side', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      await _pickPlayer(tester, 1, 0, p2);

      expect(
        find.descendant(
          of: _slot(0, 0),
          matching: find.text('Pick player'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _slot(1, 0), matching: find.text(p2)),
        findsOneWidget,
      );
    });

    testWidgets('tapping a slot opens the player picker', (tester) async {
      await _pumpSetupPage(tester);

      await tester.tap(_slot(0, 0));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerPickerDialog), findsOneWidget);
    });

    testWidgets('picking a player fills the slot', (tester) async {
      await _pumpSetupPage(tester);
      await _pickPlayer(tester, 0, 0, p1);

      expect(find.byType(PlayerPickerDialog), findsNothing);
      expect(find.text(p1), findsOneWidget);
    });

    testWidgets('cancelling the picker leaves the slot empty', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      await tester.tap(_slot(0, 0));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(PlayerPickerDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayerPickerDialog), findsNothing);
      expect(find.text('Pick player'), findsNWidgets(2));
    });
  });

  group('start', () {
    testWidgets('shows a snackbar and does not navigate when empty', (
      tester,
    ) async {
      await _pumpSetupPage(tester);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(MatchPage), findsNothing);
    });

    testWidgets('shows a snackbar when only one side is filled', (
      tester,
    ) async {
      await _pumpSetupPage(tester);
      await _pickPlayer(tester, 0, 0, p1);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(MatchPage), findsNothing);
    });

    testWidgets('navigate to match page when both side filled', (tester) async {
      await _pumpSetupPage(tester);
      await _pickPlayer(tester, 0, 0, p1);
      await _pickPlayer(tester, 1, 0, p2);

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsOneWidget);
      expect(find.byType(MatchSetupPage), findsNothing);
    });
  });

  group('cancel', () {
    testWidgets('pops the setup page', (tester) async {
      await _pumpStackedSetupPage(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchSetupPage), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('content is capped at the content max width', (tester) async {
      await _pumpSetupPage(tester, size: const Size(1600, 1200));

      final size = tester.getSize(
        find.byKey(const ValueKey('setup-content')),
      );

      expect(size.width, LayoutBreakpoints.contentMax);
    });

    testWidgets('iPhone SE width does not overflow', (tester) async {
      await _pumpSetupPage(tester, size: const Size(375, 667));

      expect(tester.takeException(), isNull);
    });

    testWidgets('iPhone SE width does not overflow at 2x text scale', (
      tester,
    ) async {
      _setTextScale(tester, 2);
      await _pumpSetupPage(tester, size: const Size(375, 667));

      expect(tester.takeException(), isNull);
    });
  });
}
