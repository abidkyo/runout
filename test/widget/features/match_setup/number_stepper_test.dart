import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';

void main() {
  group('NumberStepper — rendering', () {
    testWidgets('renders the value', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders all four step buttons', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      expect(find.text('-10'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('+10'), findsOneWidget);
    });
  });

  group('NumberStepper — tap', () {
    testWidgets('tapping +1 emits value + 1', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.text('+1'));
      await tester.pump();

      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('tapping -1 emits value - 1', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.text('-1'));
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('tapping +10 emits value + 10', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.text('+10'));
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('tapping -10 emits value - 10', (tester) async {
      await tester.pumpWidget(_host(value: 25, min: 1, max: 99));

      await tester.tap(find.text('-10'));
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });
  });

  group('NumberStepper — bounds', () {
    testWidgets('at min, decrement buttons are disabled', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(
        _host(value: 1, min: 1, max: 99, onChanged: calls.add),
      );

      await tester.tap(find.text('-1'));
      await tester.tap(find.text('-10'));
      await tester.pump();

      expect(calls, isEmpty);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('at max, increment buttons are disabled', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(
        _host(value: 99, min: 1, max: 99, onChanged: calls.add),
      );

      await tester.tap(find.text('+1'));
      await tester.tap(find.text('+10'));
      await tester.pump();

      expect(calls, isEmpty);
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('+10 clamps to max instead of overshooting', (tester) async {
      await tester.pumpWidget(_host(value: 95, min: 1, max: 99));

      await tester.tap(find.text('+10'));
      await tester.pump();

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('-10 clamps to min instead of overshooting', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.text('-10'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('NumberStepper — long-press repeat', () {
    testWidgets('holding +1 fires once immediately and repeats on the timer', (
      tester,
    ) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('+1')),
      );
      // Advance past the long-press threshold so onLongPressStart fires.
      await tester.pump(const Duration(milliseconds: 600));

      // _startRepeat fires immediately.
      expect(find.text('6'), findsOneWidget);

      // One repeat tick.
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('7'), findsOneWidget);

      // Another tick.
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('8'), findsOneWidget);

      await gesture.up();
      await tester.pump();
    });
  });

  group('NumberStepper — layout', () {
    testWidgets('narrow width puts the step pairs beside the value', (
      tester,
    ) async {
      _setWidth(tester, 349);
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      final value = tester.getCenter(find.text('5'));
      final minusOne = tester.getCenter(find.text('-1'));
      final plusOne = tester.getCenter(find.text('+1'));
      final minusTen = tester.getCenter(find.text('-10'));
      final plusTen = tester.getCenter(find.text('+10'));

      expect(minusOne.dy, plusOne.dy);
      expect(minusTen.dy, plusTen.dy);
      expect(minusTen.dy, greaterThan(minusOne.dy));
      expect(value.dx, lessThan(minusOne.dx));
    });

    testWidgets('wide width puts the value between the step pairs', (
      tester,
    ) async {
      _setWidth(tester, 350);
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      final value = tester.getCenter(find.text('5'));
      final minusTen = tester.getCenter(find.text('-10'));
      final plusOne = tester.getCenter(find.text('+1'));

      expect(minusTen.dx, lessThan(value.dx));
      expect(value.dx, lessThan(plusOne.dx));
      expect(minusTen.dy, value.dy);
    });
  });

  group('NumberStepper — dynamic type', () {
    testWidgets('narrow layout does not overflow at 2x text scale', (
      tester,
    ) async {
      _setWidth(tester, 300);
      _setTextScale(tester, 2);

      await tester.pumpWidget(_host(value: 999, min: 1, max: 999));

      expect(tester.takeException(), isNull);
    });

    testWidgets('wide layout does not overflow at 2x text scale', (
      tester,
    ) async {
      _setWidth(tester, 500);
      _setTextScale(tester, 2);

      await tester.pumpWidget(_host(value: 999, min: 1, max: 999));

      expect(tester.takeException(), isNull);
    });
  });
}

// ---------------------------------------------------------------------------

void _setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// A stateful host that owns the value, so taps round-trip through [onChanged]
/// and the rendered label reflects the new value.
Widget _host({
  required int value,
  required int min,
  required int max,
  ValueChanged<int>? onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: _StepperHost(
        initialValue: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ),
  );
}

class _StepperHost extends StatefulWidget {
  const new({
    required this.initialValue,
    required this.min,
    required this.max,
    this.onChanged,
  });

  final int initialValue;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  State<_StepperHost> createState() => _StepperHostState();
}

class _StepperHostState extends State<_StepperHost> {
  late int _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return NumberStepper(
      value: _value,
      min: widget.min,
      max: widget.max,
      onChanged: (next) {
        widget.onChanged?.call(next);
        setState(() => _value = next);
      },
    );
  }
}
