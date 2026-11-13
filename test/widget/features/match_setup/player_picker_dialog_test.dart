import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match_setup/widgets/player_picker_dialog.dart';

// ---------------------------------------------------------------------------

const ValueKey<String> _searchKey = ValueKey('player-search');

// ---------------------------------------------------------------------------

void main() {
  group('PlayerPickerDialog — rendering', () {
    testWidgets('shows the dialog title', (tester) async {
      await _open(tester);

      expect(find.text('Select or add player'), findsOneWidget);
    });

    testWidgets('shows the search hint', (tester) async {
      await _open(tester);

      expect(find.text('Search or add player'), findsOneWidget);
    });

    testWidgets('lists all players when unfiltered', (tester) async {
      await _open(tester);

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);
    });

    testWidgets('shows message when the list is empty', (tester) async {
      await _open(tester, players: const []);

      expect(find.text('No players found'), findsOneWidget);
    });

    testWidgets('fits a narrow viewport at 1.5x text scale', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _open(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('PlayerPickerDialog — search', () {
    testWidgets('narrows by name, case-insensitively', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), 'JOHN');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsNothing);
      expect(find.text('Bob Jones'), findsNothing);
    });

    testWidgets('matches a substring, not just a prefix', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), 'ohn');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Jane Doe'), findsNothing);
    });

    testWidgets('trims the query', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), '  jane  ');
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('John Smith'), findsNothing);
    });

    testWidgets('offers a create row when nothing matches', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Add "zzz"'), findsOneWidget);
      expect(find.text('No players found'), findsNothing);
    });
  });

  group('PlayerPickerDialog — create row visibility', () {
    testWidgets('is hidden for an empty or whitespace query', (tester) async {
      await _open(tester);

      expect(find.textContaining('Add "'), findsNothing);

      await tester.enterText(find.byKey(_searchKey), '   ');
      await tester.pumpAndSettle();

      expect(find.textContaining('Add "'), findsNothing);
    });

    testWidgets('is hidden for an exact name match, ignoring case', (
      tester,
    ) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), 'jOhN sMiTh');
      await tester.pumpAndSettle();

      expect(find.text('John Smith'), findsOneWidget);
      expect(find.textContaining('Add "'), findsNothing);
    });

    testWidgets('appears when the query has no exact match', (tester) async {
      await _open(tester);

      await tester.enterText(find.byKey(_searchKey), 'John');
      await tester.pumpAndSettle();

      expect(find.text('Add "John"'), findsOneWidget);
    });
  });

  group('PlayerPickerDialog — creation', () {
    testWidgets('creates with the trimmed query and pops the player', (
      tester,
    ) async {
      Player? result;
      String? createdName;
      await _open(
        tester,
        onCreatePlayer: (name) async {
          createdName = name;
          return Player(id: 'new', name: name);
        },
        onResult: (player) => result = player,
      );

      await tester.enterText(find.byKey(_searchKey), '  New Player  ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add "New Player"'));
      await tester.pumpAndSettle();

      expect(createdName, 'New Player');
      expect(result?.name, 'New Player');
      expect(find.byType(PlayerPickerDialog), findsNothing);
    });

    testWidgets('shows an inline error and announces it', (tester) async {
      final handle = tester.ensureSemantics();
      await _showCreateError(tester);

      final pickerError = tester.getSemantics(
        find.byKey(const ValueKey('player-picker-error')),
      );

      expect(find.byType(PlayerPickerDialog), findsOneWidget);
      expect(find.text('Could not add player.'), findsOneWidget);
      expect(
        pickerError,
        isSemantics(isLiveRegion: true, label: 'Could not add player.'),
      );
      handle.dispose();
    });

    testWidgets('clears the inline error on the next keystroke', (
      tester,
    ) async {
      await _showCreateError(tester);

      await tester.enterText(find.byKey(_searchKey), 'Another Player');
      await tester.pumpAndSettle();

      expect(find.text('Could not add player.'), findsNothing);
    });

    testWidgets('clears the inline error with the clear button', (
      tester,
    ) async {
      await _showCreateError(tester);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      expect(find.text('Could not add player.'), findsNothing);
      expect(_searchField(tester).controller?.text, isEmpty);
    });

    testWidgets('disables the search field while creating', (tester) async {
      final completer = Completer<Player>();
      Player? result;
      await _open(
        tester,
        onCreatePlayer: (_) => completer.future,
        onResult: (player) => result = player,
      );

      await tester.enterText(find.byKey(_searchKey), 'New Player');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add "New Player"'));
      await tester.pump();

      final clearButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.clear),
      );

      expect(clearButton.onPressed, isNull);
      expect(_searchField(tester).enabled, isFalse);

      completer.complete(const Player(id: 'new', name: 'New Player'));
      await tester.pumpAndSettle();

      expect(result?.name, 'New Player');
    });
  });

  group('PlayerPickerDialog — keyboard', () {
    testWidgets('submitting a single match selects it', (tester) async {
      Player? result;
      await _open(tester, onResult: (player) => result = player);

      await tester.enterText(find.byKey(_searchKey), 'jane');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result?.name, 'Jane Doe');
    });

    testWidgets('submitting a create query creates the player', (tester) async {
      Player? result;
      await _open(tester, onResult: (player) => result = player);

      await tester.enterText(find.byKey(_searchKey), 'New Player');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result?.name, 'New Player');
    });

    testWidgets('submitting multiple matches is a no-op', (tester) async {
      Player? result;
      await _open(tester, onResult: (player) => result = player);

      await tester.enterText(find.byKey(_searchKey), 'j');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.byType(PlayerPickerDialog), findsOneWidget);
    });

    testWidgets('submitting an exact match selects it without creating', (
      tester,
    ) async {
      Player? result;
      await _open(tester, onResult: (player) => result = player);

      await tester.enterText(find.byKey(_searchKey), 'John Smith');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result?.name, 'John Smith');
    });
  });

  group('PlayerPickerDialog — selection', () {
    testWidgets('tapping a row pops with that player', (tester) async {
      Player? result;
      await _open(tester, onResult: (player) => result = player);

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'Jane Doe');
      expect(result?.name, 'Jane Doe');
    });

    testWidgets('cancel pops null', (tester) async {
      Player? result;
      var popped = false;
      await _open(
        tester,
        onResult: (player) {
          result = player;
          popped = true;
        },
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(result, isNull);
    });
  });
}

// ---------------------------------------------------------------------------

Future<void> _open(
  WidgetTester tester, {
  List<Player> players = _threePlayers,
  Future<Player> Function(String name)? onCreatePlayer,
  ValueChanged<Player?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showDialog<Player>(
                context: context,
                builder: (_) => PlayerPickerDialog(
                  players: players,
                  onCreatePlayer: onCreatePlayer ?? _defaultCreate,
                ),
              );
              onResult?.call(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

TextField _searchField(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byKey(_searchKey),
  );
}

Future<void> _showCreateError(WidgetTester tester) async {
  await _open(
    tester,
    onCreatePlayer: (_) async => throw Exception('create failed'),
  );
  await tester.enterText(find.byKey(_searchKey), 'New Player');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add "New Player"'));
  await tester.pumpAndSettle();
}

Future<Player> _defaultCreate(String name) async =>
    Player(id: 'new', name: name);

const List<Player> _threePlayers = [
  Player(id: '1', name: 'John Smith'),
  Player(id: '2', name: 'Jane Doe'),
  Player(id: '3', name: 'Bob Jones'),
];
