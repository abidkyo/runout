import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/break_format_selector.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester,
  MatchSetupNotifier notifier,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<MatchSetupNotifier>.value(
      value: notifier,
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: BreakFormatSelector()),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  late MatchSetupNotifier notifier;

  setUp(() {
    notifier = MatchSetupNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group('BreakFormatSelector — rendering', () {
    testWidgets('renders every break format', (tester) async {
      await _pump(tester, notifier);

      for (final format in BreakFormat.values) {
        expect(find.text(format.displayName), findsOneWidget);
      }
    });

    testWidgets('marks the current break format as selected', (tester) async {
      await _pump(tester, notifier);

      final winnerBreak = tester.widget<ChoiceButton>(
        find.widgetWithText(
          ChoiceButton,
          BreakFormat.winnerBreak.displayName,
        ),
      );
      expect(winnerBreak.selected, isTrue);
    });
  });

  group('BreakFormatSelector — selection', () {
    testWidgets('tapping a format updates the notifier', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text(BreakFormat.alternateBreak.displayName));
      await tester.pump();

      expect(notifier.breakFormat, BreakFormat.alternateBreak);
    });
  });
}
