import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/shared/widgets/match_card.dart';

import '../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _now = DateTime(2026, 11, 9);

Widget _host(
  Match match, {
  VoidCallback? onTap,
  double width = 360,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: MatchCard(match: match, onTap: onTap),
        ),
      ),
    ),
  );
}

Match _playingMatch() {
  return makeMatch().copyWith(
    status: MatchStatus.playing,
    scores: const [6, 4],
    startedAt: _now,
    currentBreakerIndex: 0,
  );
}

Match _finishedMatch({DateTime? endedAt}) {
  final end = endedAt ?? _now;

  return makeMatch().copyWith(
    status: MatchStatus.finished,
    scores: const [10, 7],
    startedAt: end.subtract(const Duration(hours: 2)),
    endedAt: end,
    currentBreakerIndex: 0,
    winnerIndex: 0,
  );
}

Match _threePlayerMatch() {
  return Match.create(
    id: 'three-player',
    config: makeConfig(matchMode: MatchMode.threePlayer),
    sides: [makeSide('a'), makeSide('b'), makeSide('c')],
  ).copyWith(
    status: MatchStatus.finished,
    scores: const [3, 2, 1],
    startedAt: _now.subtract(const Duration(hours: 2)),
    endedAt: _now,
    winnerIndex: 0,
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('playing', () {
    testWidgets('renders format, sides, scores, date, and continue', (
      tester,
    ) async {
      await withClock(Clock.fixed(_now), () async {
        await tester.pumpWidget(_host(_playingMatch()));
      });

      expect(find.text('8 Ball · Singles'), findsOneWidget);
      expect(find.text('Player-0'), findsOneWidget);
      expect(find.text('Player-1'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('continue action fires onTap', (tester) async {
      var calls = 0;
      await tester.pumpWidget(_host(_playingMatch(), onTap: () => calls++));

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(calls, 1);
    });
  });

  group('finished', () {
    testWidgets('shows the winner, date, and no actions', (tester) async {
      await withClock(Clock.fixed(_now), () async {
        await tester.pumpWidget(_host(_finishedMatch()));
      });

      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('winner icon has a state label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_host(_finishedMatch()));

      expect(
        tester.getSemantics(find.byIcon(Icons.emoji_events)).label,
        contains('Winner'),
      );

      handle.dispose();
    });
  });

  group('created', () {
    testWidgets('shows not started and no actions', (tester) async {
      await tester.pumpWidget(_host(makeMatch()));

      expect(find.text('Not started'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.byIcon(Icons.emoji_events), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  group('three-player', () {
    testWidgets('renders every side', (tester) async {
      await tester.pumpWidget(_host(_threePlayerMatch()));

      expect(find.text('Player-a'), findsOneWidget);
      expect(find.text('Player-b'), findsOneWidget);
      expect(find.text('Player-c'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });
  });

  group('dates', () {
    testWidgets('formats relative and absolute dates', (tester) async {
      await withClock(Clock.fixed(_now), () async {
        await tester.pumpWidget(_host(_finishedMatch(endedAt: _now)));
        expect(find.text('Today'), findsOneWidget);

        await tester.pumpWidget(
          _host(
            _finishedMatch(
              endedAt: _now.subtract(const Duration(days: 1)),
            ),
          ),
        );
        expect(find.text('Yesterday'), findsOneWidget);

        await tester.pumpWidget(
          _host(
            _finishedMatch(
              endedAt: _now.subtract(const Duration(days: 3)),
            ),
          ),
        );
        expect(find.text('3 days ago'), findsOneWidget);

        await tester.pumpWidget(
          _host(
            _finishedMatch(
              endedAt: _now.subtract(const Duration(days: 10)),
            ),
          ),
        );
        expect(find.text('30 Oct 2026'), findsOneWidget);
      });
    });
  });

  group('alignment', () {
    testWidgets('scores and date share the card right edge', (tester) async {
      await withClock(Clock.fixed(_now), () async {
        await tester.pumpWidget(_host(_finishedMatch()));
      });

      final dateRight = tester.getTopRight(find.text('Today')).dx;
      final tenRight = tester.getTopRight(find.text('10')).dx;
      final sevenRight = tester.getTopRight(find.text('7')).dx;

      expect(tenRight, moreOrLessEquals(sevenRight));
      expect(tenRight, moreOrLessEquals(dateRight));
    });
  });

  group('dynamic type', () {
    testWidgets('card does not overflow at 2x text scale', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );

      await tester.pumpWidget(
        _host(_threePlayerMatch(), width: 320),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
