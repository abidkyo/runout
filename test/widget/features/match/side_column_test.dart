import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/side_column.dart';

// ---------------------------------------------------------------------------

void main() {
  group('SideColumn', () {
    testWidgets('renders its children in order', (tester) async {
      await tester.pumpWidget(
        _host(children: const [Text('first'), Text('second')]),
      );

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('first')).dy,
        lessThan(tester.getTopLeft(find.text('second')).dy),
      );
    });

    testWidgets('fills the card with primaryContainer when winner', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(children: const [SizedBox()], isWinner: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final context = tester.element(find.byType(Card));
      expect(card.color, Theme.of(context).colorScheme.primaryContainer);
    });

    testWidgets('does not fill the card when not winner', (tester) async {
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
    });

    testWidgets('draws a primary border when breaker', (tester) async {
      await tester.pumpWidget(
        _host(children: const [SizedBox()], isBreaker: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      final context = tester.element(find.byType(Card));
      expect(shape.side.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('draws a primary border when winner', (tester) async {
      await tester.pumpWidget(
        _host(children: const [SizedBox()], isWinner: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      final context = tester.element(find.byType(Card));
      expect(shape.side.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('draws a transparent border when neither breaker nor winner', (
      tester,
    ) async {
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as RoundedRectangleBorder;
      expect(shape.side.color, Colors.transparent);
    });

    testWidgets('dims the content when loser', (tester) async {
      await tester.pumpWidget(
        _host(children: const [SizedBox()], isLoser: true),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('does not dim the content when not loser', (tester) async {
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1);
    });
  });

  group('SideColumn — tap', () {
    testWidgets('tapping the card calls onTap', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(children: const [SizedBox()], onTap: () => calls++),
      );

      await tester.tap(find.byType(SideColumn));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('tapping a child inside the card calls onTap', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _host(children: const [Text('inner')], onTap: () => calls++),
      );

      await tester.tap(find.text('inner'));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('onTap null makes the card non-tappable', (tester) async {
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });
  });

  group('SideColumn semantics', () {
    testWidgets('announces winner', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(children: const [SizedBox()], isWinner: true),
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
        _host(children: const [SizedBox()], isBreaker: true),
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
        _host(children: const [SizedBox()], isLoser: true),
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
        _host(
          children: const [SizedBox()],
          isWinner: true,
          isBreaker: true,
        ),
      );

      final label = tester.getSemantics(find.byType(SideColumn)).label;
      expect(label, contains('Winner'));
      expect(label, isNot(contains('Breaking')));
      handle.dispose();
    });

    testWidgets('no state label when neutral', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final label = tester.getSemantics(find.byType(SideColumn)).label;
      expect(label, isNot(contains('Winner')));
      expect(label, isNot(contains('Breaking')));
      expect(label, isNot(contains('Loser')));
      handle.dispose();
    });

    testWidgets('announces as a button when tappable', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(children: const [SizedBox()], onTap: () {}),
      );

      final node = tester.getSemantics(find.byType(SideColumn));
      expect(node, isSemantics(isButton: true));
      handle.dispose();
    });

    testWidgets('does not announce as a button when not tappable', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(children: const [SizedBox()]));

      final node = tester.getSemantics(find.byType(SideColumn));
      expect(node, isSemantics(isButton: false));
      handle.dispose();
    });
  });
}

// ---------------------------------------------------------------------------

Widget _host({
  required List<Widget> children,
  VoidCallback? onTap,
  bool isWinner = false,
  bool isLoser = false,
  bool isBreaker = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SideColumn(
        onTap: onTap,
        isWinner: isWinner,
        isLoser: isLoser,
        isBreaker: isBreaker,
        children: children,
      ),
    ),
  );
}
