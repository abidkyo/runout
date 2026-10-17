import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

void main() {
  group('PlayerNameDisplay', () {
    testWidgets('renders a single player full name', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(id: 'p1', firstName: 'Ada', lastName: 'Lovelace'),
          ]),
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('renders both names for a two-player side', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(id: 'p1', firstName: 'Ada', lastName: 'Lovelace'),
            _player(id: 'p2', firstName: 'Grace', lastName: 'Hopper'),
          ]),
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);
    });

    testWidgets('renders the first player club', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(
              id: 'p1',
              firstName: 'Ada',
              lastName: 'Lovelace',
              clubName: 'London',
            ),
          ]),
        ),
      );

      expect(find.text('London'), findsOneWidget);
      expect(find.text('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('does not render the second player club', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(
              id: 'p1',
              firstName: 'Ada',
              lastName: 'Lovelace',
              clubName: 'London',
            ),
            _player(
              id: 'p2',
              firstName: 'Grace',
              lastName: 'Hopper',
              clubName: 'Arlington',
            ),
          ]),
        ),
      );

      expect(find.text('London'), findsOneWidget);
      expect(find.text('Arlington'), findsNothing);
    });

    testWidgets('does not render a club line for the second player even '
        'when the first has none', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(id: 'p1', firstName: 'Ada', lastName: 'Lovelace'),
            _player(
              id: 'p2',
              firstName: 'Grace',
              lastName: 'Hopper',
              clubName: 'Arlington',
            ),
          ]),
        ),
      );

      expect(find.text('Arlington'), findsNothing);
    });
  });
}

Player _player({
  required String id,
  required String firstName,
  required String lastName,
  String? clubName,
}) => Player(
  id: id,
  firstName: firstName,
  lastName: lastName,
  clubName: clubName,
);

MatchSide _side(List<Player> players) => MatchSide(players: players);

Widget _host(MatchSide side) => MaterialApp(
  home: Scaffold(body: PlayerNameDisplay(side: side)),
);
