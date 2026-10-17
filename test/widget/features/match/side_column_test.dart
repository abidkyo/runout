import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/side_column.dart';

void main() {
  group('SideColumn', () {
    testWidgets('renders the side name display', (tester) async {
      await tester.pumpWidget(_host(child: const SizedBox()));

      final display = tester.widget<PlayerNameDisplay>(
        find.byType(PlayerNameDisplay),
      );
      expect(display.side.players.first.firstName, 'Ada');
    });

    testWidgets('renders the child', (tester) async {
      await tester.pumpWidget(_host(child: const Text('child')));

      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('does not render stats when null', (tester) async {
      await tester.pumpWidget(_host(child: const SizedBox()));

      expect(find.text('stats'), findsNothing);
    });

    testWidgets('renders stats when provided', (tester) async {
      await tester.pumpWidget(
        _host(child: const SizedBox(), stats: const Text('stats')),
      );

      expect(find.text('stats'), findsOneWidget);
    });

    testWidgets('fills the card with primaryContainer when winner', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(child: const SizedBox(), isWinner: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final context = tester.element(find.byType(Card));
      expect(card.color, Theme.of(context).colorScheme.primaryContainer);
    });

    testWidgets('does not fill the card when not winner', (tester) async {
      await tester.pumpWidget(_host(child: const SizedBox()));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
    });

    testWidgets('draws a primary border when breaker', (tester) async {
      await tester.pumpWidget(
        _host(child: const SizedBox(), isBreaker: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      final context = tester.element(find.byType(Card));
      expect(shape.side.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('draws a primary border when winner', (tester) async {
      await tester.pumpWidget(
        _host(child: const SizedBox(), isWinner: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      final context = tester.element(find.byType(Card));
      expect(shape.side.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('draws a transparent border when neither breaker nor winner', (
      tester,
    ) async {
      await tester.pumpWidget(_host(child: const SizedBox()));

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.color, Colors.transparent);
    });

    testWidgets('dims the content when loser', (tester) async {
      await tester.pumpWidget(
        _host(child: const SizedBox(), isLoser: true),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('does not dim the content when not loser', (tester) async {
      await tester.pumpWidget(_host(child: const SizedBox()));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1);
    });
  });

  group('SideColumn semantics', () {
    testWidgets('announces winner', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: const SizedBox(), isWinner: true),
      );

      expect(
        tester.getSemantics(find.byType(SideColumn)).label,
        contains('Winner'),
      );
      handle.dispose();
    });

    testWidgets('announces breaker', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: const SizedBox(), isBreaker: true),
      );

      expect(
        tester.getSemantics(find.byType(SideColumn)).label,
        contains('Breaking'),
      );
      handle.dispose();
    });

    testWidgets('announces loser', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: const SizedBox(), isLoser: true),
      );

      expect(
        tester.getSemantics(find.byType(SideColumn)).label,
        contains('Loser'),
      );
      handle.dispose();
    });

    testWidgets('winner label wins over breaker', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(child: const SizedBox(), isWinner: true, isBreaker: true),
      );

      final label = tester.getSemantics(find.byType(SideColumn)).label;
      expect(label, contains('Winner'));
      expect(label, isNot(contains('Breaking')));
      handle.dispose();
    });

    testWidgets('no state label when neutral', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(child: const SizedBox()));

      final label = tester.getSemantics(find.byType(SideColumn)).label;
      expect(label, isNot(contains('Winner')));
      expect(label, isNot(contains('Breaking')));
      expect(label, isNot(contains('Loser')));
      handle.dispose();
    });
  });
}

MatchSide _side() => MatchSide(
  players: const [
    Player(id: 'p1', firstName: 'Ada', lastName: 'Lovelace'),
  ],
);

Widget _host({
  required Widget child,
  Widget? stats,
  bool isWinner = false,
  bool isLoser = false,
  bool isBreaker = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SideColumn(
        side: _side(),
        stats: stats,
        isWinner: isWinner,
        isLoser: isLoser,
        isBreaker: isBreaker,
        child: child,
      ),
    ),
  );
}
