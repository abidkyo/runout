import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match_setup/widgets/number_stepper.dart';

void main() {
  group('NumberStepper — label rendering', () {
    testWidgets('renders the value alone when both labels are null', (
      tester,
    ) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders leadingLabel before the value', (tester) async {
      await tester.pumpWidget(
        _host(value: 5, min: 1, max: 99, leadingLabel: 'Race to'),
      );

      expect(find.text('Race to 5'), findsOneWidget);
    });

    testWidgets('renders trailingLabel after the value', (tester) async {
      await tester.pumpWidget(
        _host(value: 25, min: 1, max: 99, trailingLabel: 'innings'),
      );

      expect(find.text('25 innings'), findsOneWidget);
    });

    testWidgets('renders both labels around the value', (tester) async {
      await tester.pumpWidget(
        _host(
          value: 5,
          min: 1,
          max: 99,
          leadingLabel: 'Race to',
          trailingLabel: 'racks',
        ),
      );

      expect(find.text('Race to 5 racks'), findsOneWidget);
    });
  });

  group('NumberStepper — icons', () {
    testWidgets('renders the four step icons', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_double_arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_double_arrow_right), findsOneWidget);
    });
  });

  group('NumberStepper — tap', () {
    testWidgets('tapping + emits value + 1', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('tapping − emits value - 1', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('tapping ++ emits value + 10', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('tapping −− emits value - 10', (tester) async {
      await tester.pumpWidget(_host(value: 25, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });
  });

  group('NumberStepper — bounds', () {
    testWidgets('at min, both decrement buttons are disabled', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(
        _host(value: 1, min: 1, max: 99, onChanged: calls.add),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
      await tester.pump();

      expect(calls, isEmpty);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('at max, both increment buttons are disabled', (tester) async {
      final calls = <int>[];
      await tester.pumpWidget(
        _host(value: 99, min: 1, max: 99, onChanged: calls.add),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
      await tester.pump();

      expect(calls, isEmpty);
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('++ clamps to max instead of overshooting', (tester) async {
      await tester.pumpWidget(_host(value: 95, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
      await tester.pump();

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('−− clamps to min instead of overshooting', (tester) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('NumberStepper — long-press repeat', () {
    testWidgets('holding + fires once immediately and repeats on the timer', (
      tester,
    ) async {
      await tester.pumpWidget(_host(value: 5, min: 1, max: 99));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.add)),
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
}

// ---------------------------------------------------------------------------

/// A stateful host that owns the value, so taps round-trip through [onChanged]
/// and the rendered label reflects the new value.
Widget _host({
  required int value,
  required int min,
  required int max,
  String? leadingLabel,
  String? trailingLabel,
  ValueChanged<int>? onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: _StepperHost(
        initialValue: value,
        min: min,
        max: max,
        leadingLabel: leadingLabel,
        trailingLabel: trailingLabel,
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
    this.leadingLabel,
    this.trailingLabel,
    this.onChanged,
  });

  final int initialValue;
  final int min;
  final int max;
  final String? leadingLabel;
  final String? trailingLabel;
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
      leadingLabel: widget.leadingLabel,
      trailingLabel: widget.trailingLabel,
      onChanged: (next) {
        widget.onChanged?.call(next);
        setState(() => _value = next);
      },
    );
  }
}
