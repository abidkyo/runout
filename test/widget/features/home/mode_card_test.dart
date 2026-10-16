import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/features/home/mode_card.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  IconData icon = Icons.person,
  String label = 'Singles',
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: ModeCard(
              icon: icon,
              label: label,
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    testWidgets('renders the label', (tester) async {
      await _pump(tester);
      expect(find.text('Singles'), findsOneWidget);
    });

    testWidgets('renders the icon', (tester) async {
      await _pump(tester);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('icon uses the primary color', (tester) async {
      await _pump(tester);

      final icon = tester.widget<Icon>(find.byIcon(Icons.person));
      final context = tester.element(find.byType(ModeCard));
      expect(icon.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('icon size is 64', (tester) async {
      await _pump(tester);
      final icon = tester.widget<Icon>(find.byIcon(Icons.person));
      expect(icon.size, 64);
    });

    testWidgets('label uses the solid title style', (tester) async {
      await _pump(tester);

      final text = tester.widget<Text>(find.text('Singles'));
      final context = tester.element(find.byType(ModeCard));
      expect(text.style, Theme.of(context).textTheme.titleLargeSolid);
    });
  });

  group('tap', () {
    testWidgets('tapping the card fires onTap', (tester) async {
      var calls = 0;
      await _pump(tester, onTap: () => calls++);

      await tester.tap(find.byType(ModeCard));
      await tester.pump();

      expect(calls, 1);
    });
  });
}
