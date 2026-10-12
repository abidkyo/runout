import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match/widgets/score_button.dart';

void main() {
  group('ScoreButton', () {
    testWidgets('renders the score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreButton(score: 42, onTap: () {}),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreButton(score: 0, onTap: () {}),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders negative scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreButton(score: -15, onTap: () {}),
          ),
        ),
      );

      expect(find.text('-15'), findsOneWidget);
    });

    testWidgets('calls onTap once when tapped', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreButton(score: 3, onTap: () => calls++),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('is disabled when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreButton(score: 3, onTap: null),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });
}
