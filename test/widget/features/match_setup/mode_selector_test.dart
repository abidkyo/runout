import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';
import 'package:runout/features/match_setup/widgets/mode_selector.dart';

// ---------------------------------------------------------------------------

Widget _host(MatchSetupNotifier notifier) {
  return ChangeNotifierProvider<MatchSetupNotifier>.value(
    value: notifier,
    child: const MaterialApp(
      home: Scaffold(body: ModeSelector()),
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

  group('ModeSelector — rendering', () {
    testWidgets('renders every mode label', (tester) async {
      await tester.pumpWidget(_host(notifier));

      for (final mode in MatchMode.values) {
        expect(find.text(mode.displayName), findsOneWidget);
      }
    });

    testWidgets('marks the current mode as selected', (tester) async {
      await tester.pumpWidget(_host(notifier));

      final singles = tester.widget<ChoiceButton>(
        find.widgetWithText(ChoiceButton, MatchMode.singles.displayName),
      );
      expect(singles.selected, isTrue);
    });
  });

  group('ModeSelector — selection', () {
    testWidgets('tapping a mode updates the notifier', (tester) async {
      await tester.pumpWidget(_host(notifier));

      await tester.tap(find.text(MatchMode.doubles.displayName));
      await tester.pump();

      expect(notifier.mode, MatchMode.doubles);

      final doubles = tester.widget<ChoiceButton>(
        find.widgetWithText(ChoiceButton, MatchMode.doubles.displayName),
      );
      expect(doubles.selected, isTrue);
    });
  });
}
