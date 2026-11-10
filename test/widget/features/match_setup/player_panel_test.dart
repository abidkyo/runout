import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/player_panel.dart';

// ---------------------------------------------------------------------------

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

Widget _host(
  MatchSetupNotifier notifier, {
  void Function(int sideIndex, int slotIndex)? onSlotTap,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<MatchSetupNotifier>.value(
      value: notifier,
      child: Scaffold(
        body: PlayerPanel(
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

Player _john() => const Player(
  id: '1',
  firstName: 'John',
  lastName: 'Smith',
  countryCode: 'US',
  clubName: 'Alpha Club',
);

// ---------------------------------------------------------------------------

void main() {
  late MatchSetupNotifier notifier;

  setUp(() {
    notifier = MatchSetupNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group('PlayerPanel — labels', () {
    testWidgets('singles renders Player 1 and Player 2', (tester) async {
      await tester.pumpWidget(_host(notifier));

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('doubles renders Team A and Team B', (tester) async {
      notifier.mode = MatchMode.doubles;
      await tester.pumpWidget(_host(notifier));

      expect(find.text('Team A'), findsOneWidget);
      expect(find.text('Team B'), findsOneWidget);
    });

    testWidgets('threePlayer renders Player 1, 2, 3', (tester) async {
      notifier.mode = MatchMode.threePlayer;
      await tester.pumpWidget(_host(notifier));

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.text('Player 3'), findsOneWidget);
    });
  });

  group('PlayerPanel — slot count', () {
    testWidgets('singles renders one slot per side', (tester) async {
      await tester.pumpWidget(_host(notifier));

      expect(_allSlots(), findsNWidgets(2));
    });

    testWidgets('doubles renders two slots per side', (tester) async {
      notifier.mode = MatchMode.doubles;
      await tester.pumpWidget(_host(notifier));

      expect(_allSlots(), findsNWidgets(4));
    });

    testWidgets('threePlayer renders one slot per side', (tester) async {
      notifier.mode = MatchMode.threePlayer;
      await tester.pumpWidget(_host(notifier));

      expect(_allSlots(), findsNWidgets(3));
    });
  });

  group('PlayerPanel — slot content', () {
    testWidgets('empty slots show the pick prompt and add icon', (
      tester,
    ) async {
      await tester.pumpWidget(_host(notifier));

      expect(find.text('Pick player'), findsNWidgets(2));
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });

    testWidgets('filled slots show the club and player name', (tester) async {
      notifier.setPlayer(0, 0, _john());
      await tester.pumpWidget(_host(notifier));

      expect(find.text('Alpha Club'), findsOneWidget);
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Pick player'), findsOneWidget);
    });
  });

  group('PlayerPanel — mode', () {
    testWidgets('rebuilds when the notifier mode changes', (tester) async {
      await tester.pumpWidget(_host(notifier));

      expect(_allSlots(), findsNWidgets(2));

      notifier.mode = MatchMode.doubles;
      await tester.pump();

      expect(_allSlots(), findsNWidgets(4));
      expect(find.text('Team A'), findsOneWidget);
    });
  });

  group('PlayerPanel — layout', () {
    testWidgets('wide surface lays sides out in a horizontal Row', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.compact + 100);
      notifier.mode = MatchMode.threePlayer;
      await tester.pumpWidget(_host(notifier));

      final centers = _allSlots()
          .evaluate()
          .map((e) => tester.getCenter(find.byKey(e.widget.key!)))
          .toList();
      final yValues = centers.map((c) => c.dy).toSet();
      expect(yValues.length, 1);
    });

    testWidgets('narrow surface stacks sides vertically', (tester) async {
      _setWidth(tester, LayoutBreakpoints.compact - 100);
      notifier.mode = MatchMode.threePlayer;
      await tester.pumpWidget(_host(notifier));

      final centers = _allSlots()
          .evaluate()
          .map((e) => tester.getCenter(find.byKey(e.widget.key!)))
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
        _host(notifier, onSlotTap: (s, i) => calls.add((s, i))),
      );

      await tester.tap(_slot(1, 0));
      await tester.pump();

      expect(calls, [(1, 0)]);
    });

    testWidgets(
      'doubles: tapping the second slot of the second side reports (1, 1)',
      (
        tester,
      ) async {
        _setWidth(tester, 1280);
        notifier.mode = MatchMode.doubles;
        final calls = <(int, int)>[];
        await tester.pumpWidget(
          _host(notifier, onSlotTap: (s, i) => calls.add((s, i))),
        );

        await tester.tap(_slot(1, 1));
        await tester.pump();

        expect(calls, [(1, 1)]);
      },
    );

    testWidgets('threePlayer: tapping the third side reports (2, 0)', (
      tester,
    ) async {
      _setWidth(tester, 1280);
      notifier.mode = MatchMode.threePlayer;
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        _host(notifier, onSlotTap: (s, i) => calls.add((s, i))),
      );

      await tester.tap(_slot(2, 0));
      await tester.pump();

      expect(calls, [(2, 0)]);
    });

    testWidgets('tapping a filled slot reports its side and slot', (
      tester,
    ) async {
      notifier.setPlayer(0, 0, _john());
      final calls = <(int, int)>[];
      await tester.pumpWidget(
        _host(notifier, onSlotTap: (s, i) => calls.add((s, i))),
      );

      await tester.tap(find.text('John Smith'));
      await tester.pump();

      expect(calls, [(0, 0)]);
    });
  });
}
