import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';

void main() {
  group('StraightPoolStats', () {
    testWidgets('renders innings, high run, and average', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: 10, innings: 5, highRun: 8),
          ),
        ),
      );

      expect(find.text('I: 5   HR: 8   Ø: 2.00'), findsOneWidget);
    });

    testWidgets('renders zero average when innings is zero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: 0, innings: 0, highRun: 0),
          ),
        ),
      );

      expect(find.text('I: 0   HR: 0   Ø: 0.00'), findsOneWidget);
    });

    testWidgets('rounds average to two decimals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: 3, innings: 2, highRun: 3),
          ),
        ),
      );

      expect(find.text('I: 2   HR: 3   Ø: 1.50'), findsOneWidget);
    });

    testWidgets('rounds repeating decimals to two decimals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: 10, innings: 3, highRun: 10),
          ),
        ),
      );

      expect(find.text('I: 3   HR: 10   Ø: 3.33'), findsOneWidget);
    });

    testWidgets('renders a negative average for a negative score', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: -15, innings: 3, highRun: 0),
          ),
        ),
      );

      expect(find.text('I: 3   HR: 0   Ø: -5.00'), findsOneWidget);
    });

    testWidgets('uses U+00D8 for the average symbol', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StraightPoolStats(score: 0, innings: 0, highRun: 0),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text)).data!;
      expect(text, contains('Ø'));
      expect(text.contains('\u00D8'), isTrue); // Ø
      expect(text.contains('\u2205'), isFalse); // ∅
      expect(text.contains('\u2298'), isFalse); // ⊘
      expect(text.contains('\u2300'), isFalse); // ⌀
    });
  });
}
