import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match_setup/widgets/setup_actions.dart';

void main() {
  group('SetupActions — rendering', () {
    testWidgets('renders both button labels', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Match'), findsOneWidget);
    });

    testWidgets('start button shows the play arrow icon', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });

  group('SetupActions — callbacks', () {
    testWidgets('tapping Cancel calls onCancel once and not onStart', (
      tester,
    ) async {
      var cancelCalls = 0;
      var startCalls = 0;
      await tester.pumpWidget(
        _host(
          onCancel: () => cancelCalls++,
          onStart: () => startCalls++,
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelCalls, 1);
      expect(startCalls, 0);
    });

    testWidgets('tapping Start Match calls onStart once and not onCancel', (
      tester,
    ) async {
      var cancelCalls = 0;
      var startCalls = 0;
      await tester.pumpWidget(
        _host(
          onCancel: () => cancelCalls++,
          onStart: () => startCalls++,
        ),
      );

      await tester.tap(find.text('Start Match'));
      await tester.pump();

      expect(startCalls, 1);
      expect(cancelCalls, 0);
    });
  });
}

// ---------------------------------------------------------------------------

Widget _host({
  VoidCallback? onStart,
  VoidCallback? onCancel,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SetupActions(
        onStart: onStart ?? () {},
        onCancel: onCancel ?? () {},
      ),
    ),
  );
}
