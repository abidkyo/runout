import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
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

  group('SetupActions — dynamic type', () {
    testWidgets('stacks without overflow at 320px and 2x text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );

      await tester.pumpWidget(_host());

      expect(tester.takeException(), isNull);
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
