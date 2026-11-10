import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/shared/widgets/match_card.dart';
import 'package:runout/shared/widgets/match_grid.dart';

import '../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

List<Match> _matches() {
  return [
    for (var i = 0; i < 2; i++)
      makeMatch().copyWith(
        id: 'match-$i',
        status: MatchStatus.finished,
        scores: const [10, 5],
        startedAt: _base,
        endedAt: _base.add(Duration(hours: i)),
        winnerIndex: 0,
      ),
  ];
}

Widget _host(double width, List<Match> matches) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MatchGrid(matches: matches, onTap: (_) {}),
        ),
      ),
    ),
  );
}

double _secondCardTop(WidgetTester tester) {
  return tester.getTopLeft(find.byType(MatchCard).at(1)).dy;
}

// ---------------------------------------------------------------------------

void main() {
  group('columns', () {
    testWidgets('stacks below the wide breakpoint', (tester) async {
      await tester.pumpWidget(
        _host(LayoutBreakpoints.wide - 1, _matches()),
      );

      final first = tester.getTopLeft(find.byType(MatchCard).at(0)).dy;
      expect(_secondCardTop(tester), greaterThan(first));
    });

    testWidgets('uses two columns at the wide breakpoint', (tester) async {
      await tester.pumpWidget(
        _host(LayoutBreakpoints.wide, _matches()),
      );

      final first = tester.getTopLeft(find.byType(MatchCard).at(0)).dy;
      expect(_secondCardTop(tester), moreOrLessEquals(first));
    });

    testWidgets('uses two columns above the wide breakpoint', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(LayoutBreakpoints.wide + 1, _matches()),
      );

      final first = tester.getTopLeft(find.byType(MatchCard).at(0)).dy;
      expect(_secondCardTop(tester), moreOrLessEquals(first));
    });
  });

  testWidgets('passes the tap callback through', (tester) async {
    final matches = _matches();
    Match? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 700,
              child: MatchGrid(
                matches: matches,
                onTap: (match) => tapped = match,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MatchCard).first);
    await tester.pump();
    expect(tapped, same(matches.first));
  });
}
