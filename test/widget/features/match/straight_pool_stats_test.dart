import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';

// ---------------------------------------------------------------------------

Widget _host({int score = 0, int innings = 0, int highRun = 0}) {
  return MaterialApp(
    home: StraightPoolStats(
      score: score,
      innings: innings,
      highRun: highRun,
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('StraightPoolStats', () {
    testWidgets('renders innings', (tester) async {
      await tester.pumpWidget(_host(innings: 5));
      expect(find.text('INN: 5'), findsOneWidget);
    });

    testWidgets('renders high run', (tester) async {
      await tester.pumpWidget(_host(highRun: 8));
      expect(find.text('HIGH: 8'), findsOneWidget);
    });

    testWidgets('renders average', (tester) async {
      await tester.pumpWidget(_host(score: 10, innings: 5));
      expect(find.text('AVG: 2.00'), findsOneWidget);
    });

    testWidgets('renders zero average when innings is zero', (tester) async {
      await tester.pumpWidget(_host());
      expect(find.text('AVG: 0.00'), findsOneWidget);
    });

    testWidgets('rounds average to two decimals', (tester) async {
      await tester.pumpWidget(_host(score: 3, innings: 2));
      expect(find.text('AVG: 1.50'), findsOneWidget);
    });

    testWidgets('rounds repeating decimals to two decimals', (tester) async {
      await tester.pumpWidget(_host(score: 10, innings: 3));
      expect(find.text('AVG: 3.33'), findsOneWidget);
    });

    testWidgets('renders a negative average for a negative score', (
      tester,
    ) async {
      await tester.pumpWidget(_host(score: -15, innings: 3));
      expect(find.text('AVG: -5.00'), findsOneWidget);
    });

    testWidgets('fits at 2x text scale on a 375px screen', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(_host(score: 999, innings: 10, highRun: 999));

      expect(tester.takeException(), isNull);
      expect(find.text('INN: 10'), findsOneWidget);
      expect(find.text('HIGH: 999'), findsOneWidget);
      expect(find.text('AVG: 99.90'), findsOneWidget);
    });
  });
}
