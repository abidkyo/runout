import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';
import 'package:runout/features/match_setup/widgets/player_slot.dart';

// ---------------------------------------------------------------------------

Widget _host(
  MatchMode mode, {
  void Function(int sideIndex, int slotIndex)? onSlotTap,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => MatchSetupNotifier(mode: mode),
      child: Scaffold(
        body: PlayerPanel(
          mode: mode,
          onSlotTap: onSlotTap ?? (_, _) {},
        ),
      ),
    ),
  );
}

void _setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// ---------------------------------------------------------------------------

void main() {
  group('PlayerPanel — labels', () {
    testWidgets('singles renders Player 1 and Player 2', (tester) async {
      await tester.pumpWidget(_host(MatchMode.singles));

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('doubles renders Team A and Team B', (tester) async {
      await tester.pumpWidget(_host(MatchMode.doubles));

      expect(find.text('Team A'), findsOneWidget);
      expect(find.text('Team B'), findsOneWidget);
    });

    testWidgets('threePlayer renders Player 1, 2, 3', (tester) async {
      await tester.pumpWidget(_host(MatchMode.threePlayer));

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.text('Player 3'), findsOneWidget);
    });
  });

  group('PlayerPanel — slot count', () {
    testWidgets('singles renders one slot per side', (tester) async {
      await tester.pumpWidget(_host(MatchMode.singles));

      expect(find.byType(PlayerSlot), findsNWidgets(2));
    });

    testWidgets('doubles renders two slots per side', (tester) async {
      await tester.pumpWidget(_host(MatchMode.doubles));

      expect(find.byType(PlayerSlot), findsNWidgets(4));
    });

    testWidgets('threePlayer renders one slot per side', (tester) async {
      await tester.pumpWidget(_host(MatchMode.threePlayer));

      expect(find.byType(PlayerSlot), findsNWidgets(3));
    });
  });

  group('PlayerPanel — layout', () {
    testWidgets('wide surface lays sides out in a horizontal Row', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.compact + 100);
      await tester.pumpWidget(_host(MatchMode.threePlayer));

      // Three side blocks share a single horizontal band: all slots
      // share the same vertical center-ish baseline region.
      final boxes = tester
          .widgetList<PlayerSlot>(find.byType(PlayerSlot))
          .toList();
      expect(boxes, hasLength(3));

      final centers = find
          .byType(PlayerSlot)
          .evaluate()
          .map((e) => tester.getCenter(find.byWidget(e.widget)))
          .toList();
      final yValues = centers.map((c) => c.dy).toSet();
      expect(yValues.length, 1);
    });

    testWidgets('narrow surface stacks sides vertically', (tester) async {
      _setWidth(tester, LayoutBreakpoints.compact - 100);
      await tester.pumpWidget(_host(MatchMode.threePlayer));

      final centers = find
          .byType(PlayerSlot)
          .evaluate()
          .map((e) => tester.getCenter(find.byWidget(e.widget)))
          .toList();
      final yValues = centers.map((c) => c.dy).toSet();
      expect(yValues.length, 3);
    });
  });

  group('PlayerPanel — onSlotTap', () {
    testWidgets('singles: tapping the second side reports (1, 0)', (
      tester,
    ) async {
      _setWidth(tester, 1280);
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        _host(MatchMode.singles, onSlotTap: (s, i) => calls.add((s, i))),
      );

      await tester.tap(find.byType(PlayerSlot).at(1));
      await tester.pump();

      expect(calls, [(1, 0)]);
    });

    testWidgets(
      'doubles: tapping the second slot of the second side reports (1, 1)',
      (
        tester,
      ) async {
        _setWidth(tester, 1280);
        final calls = <(int, int)>[];
        await tester.pumpWidget(
          _host(MatchMode.doubles, onSlotTap: (s, i) => calls.add((s, i))),
        );

        await tester.tap(find.byType(PlayerSlot).at(3));
        await tester.pump();

        expect(calls, [(1, 1)]);
      },
    );

    testWidgets('threePlayer: tapping the third side reports (2, 0)', (
      tester,
    ) async {
      _setWidth(tester, 1280);
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        _host(MatchMode.threePlayer, onSlotTap: (s, i) => calls.add((s, i))),
      );

      await tester.tap(find.byType(PlayerSlot).at(2));
      await tester.pump();

      expect(calls, [(2, 0)]);
    });
  });
}
