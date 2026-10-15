import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/features/match/widgets/ball_button.dart';
import 'package:runout/features/match/widgets/new_rack_picker_dialog.dart';

// ---------------------------------------------------------------------------

Future<void> _openDialog(
  WidgetTester tester, {
  required ValueChanged<int?> onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: _Host(onResult: onResult),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

class _Host extends StatelessWidget {
  const new({required this.onResult});

  final ValueChanged<int?> onResult;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await showDialog<int>(
          context: context,
          builder: (_) => const NewRackPickerDialog(),
        );
        onResult(result);
      },
      child: const Text('open'),
    );
  }
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the title', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('How many balls left?'), findsOneWidget);
    });

    testWidgets('renders exactly two balls', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.byType(BallButton), findsNWidgets(2));
    });

    testWidgets('renders values 0 and 1', (tester) async {
      await _openDialog(tester, onResult: (_) {});
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('return value', () {
    testWidgets('tapping 0 pops 0', (tester) async {
      final results = <int?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.widgetWithText(BallButton, '0'));
      await tester.pumpAndSettle();

      expect(results, [0]);
    });

    testWidgets('tapping 1 pops 1', (tester) async {
      final results = <int?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tap(find.widgetWithText(BallButton, '1'));
      await tester.pumpAndSettle();

      expect(results, [1]);
    });

    testWidgets('barrier dismiss pops null', (tester) async {
      final results = <int?>[];
      await _openDialog(tester, onResult: results.add);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(results, [null]);
    });
  });
}
