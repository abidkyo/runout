import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';

// ---------------------------------------------------------------------------

Widget _host({int score = 0, int innings = 0, int highRun = 0}) {
  return MaterialApp(
    home: StraightPoolStats(
      score: score,
      innings: innings,
      highRun: highRun,
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('StraightPoolStats', () {
    testWidgets('renders innings', (tester) async {
      await tester.pumpWidget(_host(innings: 5));
      expect(find.text('I: 5'), findsOneWidget);
    });

    testWidgets('renders high run', (tester) async {
      await tester.pumpWidget(_host(highRun: 8));
      expect(find.text('HR: 8'), findsOneWidget);
    });

    testWidgets('renders average', (tester) async {
      await tester.pumpWidget(_host(score: 10, innings: 5));
      expect(find.text('Ø: 2.00'), findsOneWidget);
    });

    testWidgets('renders zero average when innings is zero', (tester) async {
      await tester.pumpWidget(_host());
      expect(find.text('Ø: 0.00'), findsOneWidget);
    });

    testWidgets('rounds average to two decimals', (tester) async {
      await tester.pumpWidget(_host(score: 3, innings: 2));
      expect(find.text('Ø: 1.50'), findsOneWidget);
    });

    testWidgets('rounds repeating decimals to two decimals', (tester) async {
      await tester.pumpWidget(_host(score: 10, innings: 3));
      expect(find.text('Ø: 3.33'), findsOneWidget);
    });

    testWidgets('renders a negative average for a negative score', (
      tester,
    ) async {
      await tester.pumpWidget(_host(score: -15, innings: 3));
      expect(find.text('Ø: -5.00'), findsOneWidget);
    });

    testWidgets('uses U+00D8 for the average symbol', (tester) async {
      await tester.pumpWidget(_host());
      final text = tester.widget<Text>(find.textContaining('Ø')).data!;
      expect(text.contains('\u00D8'), isTrue); // Ø
      expect(text.contains('\u2205'), isFalse); // ∅
      expect(text.contains('\u2298'), isFalse); // ⊘
      expect(text.contains('\u2300'), isFalse); // ⌀
    });
  });
}
