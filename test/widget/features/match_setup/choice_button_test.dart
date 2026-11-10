import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';

// ---------------------------------------------------------------------------

Widget _host({
  bool selected = false,
  IconData? icon,
  VoidCallback? onPressed,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ChoiceButton(
          label: 'Singles',
          selected: selected,
          icon: icon,
          onPressed: onPressed ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('ChoiceButton — state', () {
    testWidgets('uses a filled button when selected', (tester) async {
      await tester.pumpWidget(_host(selected: true));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('uses an outlined button when unselected', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('ChoiceButton — icon', () {
    testWidgets('shows the icon when provided', (tester) async {
      await tester.pumpWidget(_host(icon: Icons.person));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows no icon when omitted', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byIcon(Icons.person), findsNothing);
    });
  });

  group('ChoiceButton — callback', () {
    testWidgets('tapping calls onPressed once', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(onPressed: () => calls++));

      await tester.tap(find.text('Singles'));
      await tester.pump();

      expect(calls, 1);
    });
  });
}
