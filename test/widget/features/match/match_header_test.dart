import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/features/match/match_timer_notifier.dart';
import 'package:runout/features/match/widgets/match_header.dart';
import 'package:runout/features/match/widgets/match_timer.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

class _FakeTimerNotifier extends ChangeNotifier implements MatchTimerNotifier {
  new(this.formatted);

  @override
  final String formatted;

  @override
  Duration get elapsed => throw UnimplementedError();
}

Widget _host({
  bool straightPool = false,
  int raceTo = 10,
  int inningsLimit = 1,
}) {
  final config = straightPool
      ? makeStraightPoolConfig(raceTo: raceTo, inningsLimit: inningsLimit)
      : makeConfig(raceTo: raceTo);

  return ChangeNotifierProvider<MatchTimerNotifier>(
    create: (_) => _FakeTimerNotifier('02:03'),
    child: MaterialApp(
      home: Scaffold(
        body: MatchHeader(config: config),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('MatchHeader', () {
    testWidgets('renders the full game name', (tester) async {
      await tester.pumpWidget(_host(straightPool: true));

      expect(find.text('Straight Pool'), findsOneWidget);
    });

    testWidgets('renders the race target and innings for straight pool', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(straightPool: true, raceTo: 150, inningsLimit: 50),
      );

      expect(find.text('Race to 150 / 50 innings'), findsOneWidget);
    });

    testWidgets('renders only the race target for non-straight-pool games', (
      tester,
    ) async {
      await tester.pumpWidget(_host(raceTo: 7));

      expect(find.text('Race to 7'), findsOneWidget);
    });

    testWidgets('renders the timer', (tester) async {
      await tester.pumpWidget(_host());

      expect(find.byType(MatchTimer), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.text('02:03'), findsOneWidget);
    });

    testWidgets('fits at 2x text scale on a 375px screen', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(_host(straightPool: true));

      expect(tester.takeException(), isNull);
    });
  });
}
