import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.light(error: Colors.red),
      ),
      home: ConfirmDialog(
        title: 'Leave match?',
        message: 'Are you sure?',
        confirmLabel: 'Leave',
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    ),
  );
}

Future<void> _showDialog(
  WidgetTester tester, {
  required ValueChanged<bool?> onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => const ConfirmDialog(
                title: 'Leave match?',
                message: 'Are you sure?',
                confirmLabel: 'Leave',
              ),
            );
            onResult(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _showConfirmDialog(
  WidgetTester tester, {
  required ValueChanged<bool?> onResult,
  bool barrierDismissible = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showConfirmDialog(
              context,
              title: 'Leave match?',
              message: 'Are you sure?',
              confirmLabel: 'Leave',
              barrierDismissible: barrierDismissible,
            );
            onResult(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------

void main() {
  group('ConfirmDialog', () {
    testWidgets('renders title, message, and both labels', (tester) async {
      await _pump(tester);

      expect(find.text('Leave match?'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('uses custom cancelLabel when provided', (tester) async {
      await _pump(tester, cancelLabel: 'Stay');

      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('confirm button uses error color when destructive', (
      tester,
    ) async {
      await _pump(tester, destructive: true);

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Leave'),
      );
      final style = button.style!;
      expect(style.foregroundColor!.resolve({}), Colors.red);
    });

    testWidgets('confirm button uses default color when not destructive', (
      tester,
    ) async {
      await _pump(tester);

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Leave'),
      );
      final style = button.style!;
      expect(style.foregroundColor, isNull);
    });

    testWidgets('tapping confirm pops true', (tester) async {
      final results = <bool?>[];
      await _showDialog(tester, onResult: results.add);

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(results, [true]);
    });

    testWidgets('tapping cancel pops false', (tester) async {
      final results = <bool?>[];
      await _showDialog(tester, onResult: results.add);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [false]);
    });

    testWidgets('both buttons share the same padding', (tester) async {
      await _pump(tester);

      final confirm = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Leave'),
      );
      final cancel = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Cancel'),
      );

      expect(confirm.style!.padding!.resolve({}), const EdgeInsets.all(12));
      expect(cancel.style!.padding!.resolve({}), const EdgeInsets.all(12));
    });
  });

  group('showConfirmDialog', () {
    testWidgets('returns true when confirmed', (tester) async {
      final results = <bool?>[];
      await _showConfirmDialog(tester, onResult: results.add);

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(results, [true]);
    });

    testWidgets('returns false when cancelled', (tester) async {
      final results = <bool?>[];
      await _showConfirmDialog(tester, onResult: results.add);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [false]);
    });

    testWidgets('returns false on barrier dismiss', (tester) async {
      final results = <bool?>[];
      await _showConfirmDialog(tester, onResult: results.add);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(results, [false]);
    });

    testWidgets('stays open when barrier dismiss is disabled', (
      tester,
    ) async {
      final results = <bool?>[];
      await _showConfirmDialog(
        tester,
        onResult: results.add,
        barrierDismissible: false,
      );

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(results, isEmpty);
      expect(find.text('Leave match?'), findsOneWidget);
    });
  });
}
