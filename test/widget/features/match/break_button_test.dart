import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match/widgets/break_button.dart';

void main() {
  group('BreakButton', () {
    testWidgets('renders the prompt text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreakButton(onTap: () {}),
          ),
        ),
      );

      expect(find.text('Who breaks?'), findsOneWidget);
    });

    testWidgets('calls onTap once when tapped', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreakButton(onTap: () => calls++),
          ),
        ),
      );

      await tester.tap(find.text('Who breaks?'));
      await tester.pump();

      expect(calls, 1);
    });
  });
}
