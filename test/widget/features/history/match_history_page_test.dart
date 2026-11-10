import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/history/match_history_page.dart';
import 'package:runout/shared/widgets/match_card.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

Match _playingMatch() {
  return makeMatch().copyWith(
    id: 'playing',
    status: MatchStatus.playing,
    startedAt: _base,
    currentBreakerIndex: 0,
  );
}

Match _finishedMatch(int index) {
  return makeMatch().copyWith(
    id: 'finished-$index',
    status: MatchStatus.finished,
    scores: const [10, 5],
    startedAt: _base.add(Duration(days: index)),
    endedAt: _base.add(Duration(days: index, hours: 1)),
    winnerIndex: 0,
  );
}

Widget _host(MatchRepository repository) {
  return Provider<MatchRepository>.value(
    value: repository,
    child: const MaterialApp(
      home: Scaffold(body: MatchHistoryPage()),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  testWidgets('lists only finished matches', (tester) async {
    await tester.pumpWidget(
      _host(
        MatchRepository(
          matches: [_playingMatch(), _finishedMatch(0), _finishedMatch(1)],
        ),
      ),
    );

    expect(find.text('Match History'), findsOneWidget);
    expect(find.byType(MatchCard), findsNWidgets(2));
    expect(find.text('No finished matches'), findsNothing);
  });

  testWidgets('cards are display-only', (tester) async {
    await tester.pumpWidget(
      _host(MatchRepository(matches: [_finishedMatch(0)])),
    );

    final card = tester.widget<MatchCard>(find.byType(MatchCard));
    expect(card.onTap, isNull);
  });

  testWidgets('shows an empty state without finished matches', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(MatchRepository(matches: [_playingMatch()])),
    );

    expect(find.text('No finished matches'), findsOneWidget);
    expect(find.byType(MatchCard), findsNothing);
  });
}
