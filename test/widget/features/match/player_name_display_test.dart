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
            _player(id: 'p1', name: 'Ada Lovelace'),
          ]),
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
    });

    testWidgets('renders both names for a two-player side', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(id: 'p1', name: 'Ada Lovelace'),
            _player(id: 'p2', name: 'Grace Hopper'),
          ]),
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
    });

    testWidgets('renders a icon for winner', (tester) async {
      await tester.pumpWidget(
        _host(
          _side([
            _player(id: 'p1', name: 'Ada Lovelace'),
          ]),
          isWinner: true,
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });
  });
}

Player _player({required String id, required String name, String? clubName}) {
  return Player(id: id, name: name, clubName: clubName);
}

MatchSide _side(List<Player> players) => MatchSide(players: players);

Widget _host(MatchSide side, {bool isWinner = false}) {
  return MaterialApp(
    home: Scaffold(
      body: PlayerNameDisplay(side: side, isWinner: isWinner),
    ),
  );
}
