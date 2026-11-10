import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/choice_button.dart';
import 'package:runout/features/match_setup/widgets/game_type_selector.dart';

// ---------------------------------------------------------------------------

Future<void> _pump(WidgetTester tester, MatchSetupNotifier notifier) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<MatchSetupNotifier>.value(
      value: notifier,
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: GameTypeSelector()),
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

  group('GameTypeSelector — rendering', () {
    testWidgets('renders every game type', (tester) async {
      await _pump(tester, notifier);

      for (final game in GameType.values) {
        expect(find.text(game.displayName), findsOneWidget);
      }
    });

    testWidgets('marks the current game type as selected', (tester) async {
      await _pump(tester, notifier);

      final eightBall = tester.widget<ChoiceButton>(
        find.widgetWithText(ChoiceButton, GameType.eightBall.displayName),
      );
      expect(eightBall.selected, isTrue);
    });
  });

  group('GameTypeSelector — selection', () {
    testWidgets('tapping a game updates the notifier', (tester) async {
      await _pump(tester, notifier);

      await tester.tap(find.text(GameType.straightPool.displayName));
      await tester.pump();

      expect(notifier.gameType, GameType.straightPool);

      final straightPool = tester.widget<ChoiceButton>(
        find.widgetWithText(ChoiceButton, GameType.straightPool.displayName),
      );
      expect(straightPool.selected, isTrue);
    });
  });
}
