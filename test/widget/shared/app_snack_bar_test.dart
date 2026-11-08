import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/shared/widgets/app_snack_bar.dart';

// ---------------------------------------------------------------------------

void main() {
  testWidgets('shows the message with a close icon', (tester) async {
    await tester.pumpWidget(_host());

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------

Widget _host() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showAppSnackBar(context, 'Saved'),
          child: const Text('show'),
        ),
      ),
    ),
  );
}
