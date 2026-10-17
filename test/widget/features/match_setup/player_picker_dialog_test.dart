import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';

const ValueKey<String> _searchKey = ValueKey('player-search');

void main() {
  group('PlayerPickerDialog — rendering', () {
    testWidgets('shows the dialog title', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Pick Player'), findsOneWidget);
    });

    testWidgets('lists all players when unfiltered', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);
    });

    testWidgets('shows "No players" when nothing matches', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No players'), findsOneWidget);
    });
  });

  group('PlayerPickerDialog — search', () {
    testWidgets('narrows by first name', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'jane');
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('John Smith'), findsNothing);
      expect(find.text('Bob Jones'), findsNothing);
    });

    testWidgets('narrows by last name', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'jones');
      await tester.pumpAndSettle();

      expect(find.text('Bob Jones'), findsOneWidget);
      expect(find.text('John Smith'), findsNothing);
      expect(find.text('Jane Doe'), findsNothing);
    });

    testWidgets('narrows by full name with a space', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'john smith');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsNothing);
      expect(find.text('Bob Jones'), findsNothing);
    });

    testWidgets('is case-insensitive', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'JOHN');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsNothing);
    });

    testWidgets('matches a substring, not just a prefix', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), 'ohn');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
    });

    testWidgets('whitespace-only query returns all players', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(_searchKey), '   ');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);
    });
  });

  group('PlayerPickerDialog — club dropdown', () {
    testWidgets('lists "All" plus unique clubs, sorted', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownMenu<String?>));
      await tester.pumpAndSettle();

      // Overlay entries: All, Alpha Club, Beta Club, (no club for Bob).
      expect(find.widgetWithText(MenuItemButton, 'All'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'Alpha Club'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'Beta Club'), findsOneWidget);
    });

    testWidgets('selecting a club filters the list', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownMenu<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Alpha Club'));
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsNothing);
      expect(find.text('Bob Jones'), findsOneWidget);
    });
  });

  group('PlayerPickerDialog — combined', () {
    testWidgets('search and club filter compose (AND)', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownMenu<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Alpha Club'));
      await tester.pumpAndSettle();

      // Within Alpha Club, search for a name that isn't there.
      await tester.enterText(find.byKey(_searchKey), 'jane');
      await tester.pumpAndSettle();

      expect(find.text('No players'), findsOneWidget);
    });
  });

  group('PlayerPickerDialog — selection', () {
    testWidgets('tapping a row pops with that player', (tester) async {
      Player? result;
      await tester.pumpWidget(
        _host(players: _threePlayers(), onResult: (p) => result = p),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.fullName, 'Jane Doe');
    });

    testWidgets('cancel pops null', (tester) async {
      Player? result;
      var popped = false;
      await tester.pumpWidget(
        _host(
          players: _threePlayers(),
          onResult: (p) {
            result = p;
            popped = true;
          },
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(result, isNull);
    });
  });

  group('PlayerPickerDialog — row', () {
    testWidgets('leading shows countryCode', (tester) async {
      await tester.pumpWidget(_host(players: _threePlayers()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('US'), findsOneWidget);
      expect(find.text('DE'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------

/// A host that opens the dialog and captures its result.
Widget _host({
  required List<Player> players,
  ValueChanged<Player?>? onResult,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await showDialog<Player>(
              context: context,
              builder: (_) => PlayerPickerDialog(players: players),
            );
            onResult?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
}

/// Three players: two with clubs, one without; one without a country code.
List<Player> _threePlayers() => const [
  Player(
    id: '1',
    firstName: 'John',
    lastName: 'Smith',
    countryCode: 'US',
    clubName: 'Alpha Club',
  ),
  Player(
    id: '2',
    firstName: 'Jane',
    lastName: 'Doe',
    countryCode: 'DE',
    clubName: 'Beta Club',
  ),
  Player(
    id: '3',
    firstName: 'Bob',
    lastName: 'Jones',
    clubName: 'Alpha Club',
  ),
];
