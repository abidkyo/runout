import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_list_notifier.dart';

import '../../helpers/factories.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  Match playingMatch() => makeMatch().copyWith(
    id: 'playing',
    status: MatchStatus.playing,
    startedAt: DateTime(2026),
    currentSideIndex: 0,
  );

  Match finishedMatch() => makeMatch().copyWith(
    id: 'finished',
    status: MatchStatus.finished,
    startedAt: DateTime(2026),
    endedAt: DateTime(2026, 1, 2),
    winnerIndex: 0,
  );

  test('delegates playing and finished queries', () {
    final playing = playingMatch();
    final finished = finishedMatch();
    final notifier = MatchListNotifier(
      FakeMatchRepository(matches: [playing, finished]),
    );
    addTearDown(notifier.dispose);

    expect(notifier.getPlaying(), [playing]);
    expect(notifier.getFinished(), [finished]);
    expect(notifier.getFinished(limit: 0), isEmpty);
  });

  test('refresh notifies listeners', () {
    final notifier = MatchListNotifier(FakeMatchRepository());
    addTearDown(notifier.dispose);
    var notifyCount = 0;
    notifier
      ..addListener(() => notifyCount++)
      ..refresh();

    expect(notifyCount, 1);
  });
}
