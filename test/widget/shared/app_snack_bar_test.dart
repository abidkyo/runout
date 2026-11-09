import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';

// ---------------------------------------------------------------------------

void main() {
  testWidgets('shows the message with a close icon when there is no action', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('UNDO'), findsNothing);
  });

  testWidgets('shows the action and hides the close icon', (tester) async {
    var calls = 0;

    await tester.pumpWidget(_host(onPressed: () => calls++));

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('Deleted'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });
}

// ---------------------------------------------------------------------------

Widget _host({VoidCallback? onPressed}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showAppSnackBar(
            context,
            onPressed == null ? 'Saved' : 'Deleted',
            action: onPressed == null
                ? null
                : SnackBarAction(label: 'UNDO', onPressed: onPressed),
          ),
          child: const Text('show'),
        ),
      ),
    ),
  );
}
