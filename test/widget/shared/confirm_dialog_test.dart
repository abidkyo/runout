import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('renders title, message, and both labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Leave match?',
            message: 'Are you sure?',
            confirmLabel: 'Leave',
          ),
        ),
      );

      expect(find.text('Leave match?'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('uses custom cancelLabel when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Leave match?',
            message: 'Are you sure?',
            confirmLabel: 'Leave',
            cancelLabel: 'Stay',
          ),
        ),
      );

      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('confirm button uses error color when destructive', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(error: Colors.red),
          ),
          home: const ConfirmDialog(
            title: 'Leave match?',
            message: 'Are you sure?',
            confirmLabel: 'Leave',
            destructive: true,
          ),
        ),
      );

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Leave'),
      );
      final style = button.style!;
      expect(style.foregroundColor!.resolve({}), Colors.red);
    });

    testWidgets('confirm button uses default color when not destructive', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Leave match?',
            message: 'Are you sure?',
            confirmLabel: 'Leave',
          ),
        ),
      );

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Leave'),
      );
      final style = button.style!;
      expect(style.foregroundColor, isNull);
    });

    testWidgets('tapping confirm pops true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmDialog(
                    title: 'Leave match?',
                    message: 'Are you sure?',
                    confirmLabel: 'Leave',
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('tapping cancel pops false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmDialog(
                    title: 'Leave match?',
                    message: 'Are you sure?',
                    confirmLabel: 'Leave',
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('both buttons share the same padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Leave match?',
            message: 'Are you sure?',
            confirmLabel: 'Leave',
          ),
        ),
      );

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
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showConfirmDialog(
                  context,
                  title: 'Leave match?',
                  message: 'Are you sure?',
                  confirmLabel: 'Leave',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showConfirmDialog(
                  context,
                  title: 'Leave match?',
                  message: 'Are you sure?',
                  confirmLabel: 'Leave',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('returns false on barrier dismiss', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showConfirmDialog(
                  context,
                  title: 'Leave match?',
                  message: 'Are you sure?',
                  confirmLabel: 'Leave',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Tap outside the dialog to dismiss it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
