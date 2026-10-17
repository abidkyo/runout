import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/ball_button.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  int value = 7,
  bool selected = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BallButton(
        value: value,
        onTap: onTap,
        selected: selected,
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

  group('selected styling', () {
    testWidgets('unselected has no background', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).style!.backgroundColor?.resolve({}), isNull);
    });

    testWidgets('unselected has no explicit foreground', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).style!.foregroundColor?.resolve({}), isNull);
    });

    testWidgets('selected uses primary as background', (tester) async {
      await _pump(tester, onTap: () {}, selected: true);

      final context = tester.element(find.byType(BallButton));
      final primary = Theme.of(context).colorScheme.primary;

      expect(_button(tester).style!.backgroundColor?.resolve({}), primary);
    });

    testWidgets('selected uses onPrimary as foreground', (tester) async {
      await _pump(tester, onTap: () {}, selected: true);

      final context = tester.element(find.byType(BallButton));
      final onPrimary = Theme.of(context).colorScheme.onPrimary;

      expect(_button(tester).style!.foregroundColor?.resolve({}), onPrimary);
    });

    testWidgets('selected removes the border side', (tester) async {
      await _pump(tester, onTap: () {}, selected: true);
      expect(
        _button(tester).style!.side?.resolve({}),
        BorderSide.none,
      );
    });

    testWidgets('unselected keeps the default border side', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).style!.side?.resolve({}), isNull);
    });
  });

  group('shape and size', () {
    testWidgets('uses a CircleBorder', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).style!.shape?.resolve({}), isA<CircleBorder>());
    });

    testWidgets('has a fixed size of 56 by 56', (tester) async {
      await _pump(tester, onTap: () {});
      expect(_button(tester).style!.fixedSize?.resolve({}), const Size(56, 56));
    });
  });
}
