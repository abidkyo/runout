import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/ball_button.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  int value = 7,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BallButton(
        value: value,
        onTap: onTap,
      ),
    ),
  );
}

OutlinedButton _button(WidgetTester tester) {
  return tester.widget<OutlinedButton>(
    find.byType(OutlinedButton),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the value', (tester) async {
      await _pump(tester, value: 8, onTap: () {});
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('renders a two-digit value', (tester) async {
      await _pump(tester, value: 15, onTap: () {});
      expect(find.text('15'), findsOneWidget);
    });
  });

  group('enabled and disabled', () {
    testWidgets('enabled when onTap is non-null', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).enabled, isTrue);
    });

    testWidgets('disabled when onTap is null', (tester) async {
      await _pump(tester);
      expect(_button(tester).enabled, isFalse);
    });

    testWidgets('tapping fires onTap', (tester) async {
      var calls = 0;
      await _pump(tester, onTap: () => calls++);

      await tester.tap(find.byType(BallButton));
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('tapping a disabled button does not throw', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(BallButton), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
