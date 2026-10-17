import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match/widgets/break_button.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/match_timer.dart';
import 'package:runout/features/match/widgets/score_button.dart';
import 'package:runout/features/match/widgets/side_column.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

Widget _host(Match match) => MaterialApp(home: MatchPage(match: match));

Future<void> _pumpStackedMatchPage(WidgetTester tester, Match match) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _StubPage(match: match),
            ),
          ),
          child: const Text('home'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('home'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('open match'));
  await tester.pumpAndSettle();
}

class _StubPage extends StatelessWidget {
  const new({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MatchPage(match: match),
            ),
          ),
          child: const Text('open match'),
        ),
      ),
    );
  }
}

Match _playingMatch() {
  return makeMatch().copyWith(
    status: MatchStatus.playing,
    currentBreakerIndex: 0,
  );
}

Match _playingSPMatch() {
  return makeStraightPoolMatch(inningsLimit: 1, raceTo: 10).copyWith(
    status: MatchStatus.playing,
    currentBreakerIndex: 0,
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    group('created', () {
      testWidgets('renders the non-straight pool title', (tester) async {
        final match = makeMatch();
        await tester.pumpWidget(_host(match));

        expect(
          find.text(
            '${match.config.gameType.displayName} — '
            'Race to ${match.config.raceTo}',
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders the straight pool title', (tester) async {
        final match = makeStraightPoolMatch(inningsLimit: 25, raceTo: 75);
        await tester.pumpWidget(_host(match));

        expect(
          find.text(
            '${match.config.gameType.displayName} — '
            'Race to ${match.config.raceTo} '
            '/ ${match.config.inningsLimit} innings',
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders one side column per side', (tester) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byType(SideColumn), findsNWidgets(2));
      });

      testWidgets(
        'renders three side columns for three-player',
        (tester) async {
          await tester.pumpWidget(_host(makeMatch(sideCount: 3)));

          expect(find.byType(SideColumn), findsNWidgets(3));
        },
      );

      testWidgets('renders a break button on each side', (tester) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byType(BreakButton), findsNWidgets(2));
      });

      testWidgets('renders the timer and controls bar', (tester) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byType(MatchTimer), findsOneWidget);
        expect(find.byType(ControlsBar), findsOneWidget);
      });

      testWidgets('straight pool stats hidden for non-straight-pool games', (
        tester,
      ) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byType(StraightPoolStats), findsNothing);
      });

      testWidgets('straight pool stats hidden when created', (tester) async {
        await tester.pumpWidget(
          _host(makeStraightPoolMatch(inningsLimit: 1, raceTo: 10)),
        );

        expect(find.byType(StraightPoolStats), findsNothing);
      });
    });

    group('playing', () {
      testWidgets('renders a score button on each side', (tester) async {
        await tester.pumpWidget(_host(_playingMatch()));

        expect(find.byType(ScoreButton), findsNWidgets(2));
        expect(find.byType(BreakButton), findsNothing);
      });

      testWidgets('marks the breaker side columns', (tester) async {
        await tester.pumpWidget(_host(_playingMatch()));

        final columns = tester
            .widgetList<SideColumn>(find.byType(SideColumn))
            .toList();
        expect(columns[0].isBreaker, isTrue);
        expect(columns[1].isBreaker, isFalse);
      });

      testWidgets('straight pool stats hidden for non-straight-pool games', (
        tester,
      ) async {
        await tester.pumpWidget(_host(_playingMatch()));

        expect(find.byType(StraightPoolStats), findsNothing);
      });

      testWidgets('renders straight pool stats', (tester) async {
        await tester.pumpWidget(_host(_playingSPMatch()));

        expect(find.byType(StraightPoolStats), findsNWidgets(2));
      });
    });

    group('finished', () {
      testWidgets('marks the winner and loser side columns', (tester) async {
        final match = makeMatch().copyWith(
          status: MatchStatus.finished,
          winnerIndex: 0,
        );
        await tester.pumpWidget(_host(match));

        final columns = tester
            .widgetList<SideColumn>(find.byType(SideColumn))
            .toList();
        expect(columns[0].isWinner, isTrue);
        expect(columns[0].isLoser, isFalse);
        expect(columns[1].isWinner, isFalse);
        expect(columns[1].isLoser, isTrue);
      });

      testWidgets('renders straight pool stats', (tester) async {
        final match = makeStraightPoolMatch(
          inningsLimit: 1,
          raceTo: 10,
        ).copyWith(status: MatchStatus.finished);
        await tester.pumpWidget(_host(match));

        expect(find.byType(StraightPoolStats), findsNWidgets(2));
      });

      testWidgets('clamps the stats innings to the effective innings limit', (
        tester,
      ) async {
        final match = makeStraightPoolMatch(
          inningsLimit: 5,
          raceTo: 10,
        ).copyWith(status: MatchStatus.finished, innings: [7, 2]);
        await tester.pumpWidget(_host(match));

        final stats = tester.widgetList<StraightPoolStats>(
          find.byType(StraightPoolStats),
        );

        expect(stats.first.innings, match.config.inningsLimit);
        expect(stats.last.innings, 2);
      });
    });
  });

  group('interactions', () {
    testWidgets('tapping a break button switches to score buttons', (
      tester,
    ) async {
      await tester.pumpWidget(_host(makeMatch()));

      await tester.tap(find.byType(BreakButton).first);
      await tester.pump();

      expect(find.byType(ScoreButton), findsNWidgets(2));
      expect(find.byType(BreakButton), findsNothing);
    });

    testWidgets('tapping a score button increments that side', (tester) async {
      await tester.pumpWidget(_host(_playingMatch()));

      final buttonsFinder = find.byType(ScoreButton);
      final buttons = tester.widgetList<ScoreButton>(buttonsFinder);

      await tester.tap(buttonsFinder.first);
      await tester.pump();

      expect(buttons.first.score, 1);
      expect(buttons.last.score, 0);
    });

    testWidgets('score button onTap is not null in non-straight-pool match', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_playingMatch()));

      final buttonsFinder = find.byType(ScoreButton);
      final buttons = tester.widgetList<ScoreButton>(buttonsFinder);

      expect(buttons.first.onTap, isNotNull);
      expect(buttons.last.onTap, isNotNull);
    });

    testWidgets('score button onTap is null in straight pool match', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_playingSPMatch()));

      final buttonsFinder = find.byType(ScoreButton);
      final buttons = tester.widgetList<ScoreButton>(buttonsFinder);

      expect(buttons.first.onTap, isNull);
      expect(buttons.last.onTap, isNull);
    });

    testWidgets('tapping a score button in straight pool match does nothing', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_playingSPMatch()));

      final buttonsFinder = find.byType(ScoreButton);
      final buttons = tester.widgetList<ScoreButton>(buttonsFinder);

      await tester.tap(buttonsFinder.first);
      await tester.pump();

      expect(buttons.first.score, 0);
      expect(buttons.last.score, 0);
    });
  });

  group('leaving', () {
    testWidgets('restart from created pops without a dialog', (tester) async {
      await _pumpStackedMatchPage(tester, makeMatch());

      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('open match'), findsOneWidget);
    });

    testWidgets('exit from created pops to the first route', (tester) async {
      await _pumpStackedMatchPage(tester, makeMatch());

      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('restart while playing then cancels out of the dialog', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();
      expect(find.byType(ConfirmDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsOneWidget);
    });

    testWidgets('restart while playing then confirms and pops one level', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('open match'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });

    testWidgets('exit while playing confirms and pops to the first route', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });
  });
}
