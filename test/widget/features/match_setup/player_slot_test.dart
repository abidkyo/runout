import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match_setup/widgets/player_slot.dart';

void main() {
  group('PlayerSlot — empty state', () {
    testWidgets('shows "Pick player" and the add icon when no player', (
      tester,
    ) async {
      await tester.pumpWidget(_host(player: null));

      expect(find.text('Pick player'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping the empty slot calls onTap', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(player: null, onTap: () => calls++));

      await tester.tap(find.byType(PlayerSlot));
      await tester.pump();

      expect(calls, 1);
    });
  });

  group('PlayerSlot — with player', () {
    testWidgets('shows the player full name', (tester) async {
      await tester.pumpWidget(_host(player: _john()));

      expect(find.text('John Smith'), findsOneWidget);
    });

    testWidgets('shows the club when present', (tester) async {
      await tester.pumpWidget(_host(player: _john()));

      expect(find.text('Alpha Club'), findsOneWidget);
    });

    testWidgets('tapping a filled slot calls onTap', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(player: _john(), onTap: () => calls++));

      await tester.tap(find.byType(PlayerSlot));
      await tester.pump();

      expect(calls, 1);
    });
  });
}

// ---------------------------------------------------------------------------

Widget _host({required Player? player, VoidCallback? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: PlayerSlot(player: player, onTap: onTap ?? () {}),
    ),
  );
}

Player _john() => const Player(
  id: '1',
  firstName: 'John',
  lastName: 'Smith',
  countryCode: 'US',
  clubName: 'Alpha Club',
);
