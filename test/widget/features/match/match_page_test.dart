import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match/widgets/controls_bar.dart';
import 'package:runout/features/match/widgets/match_timer.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/side_column.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

const ValueKey<String> _breakKey = ValueKey('break-text');
const ValueKey<String> _scoreKey = ValueKey('score-text');

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

Match _playingMatch() => makeMatch().copyWith(
  status: MatchStatus.playing,
  currentBreakerIndex: 0,
);

Match _playingSPMatch() => makeStraightPoolMatch().copyWith(
  status: MatchStatus.playing,
  currentBreakerIndex: 0,
);

void _setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Iterable<SideColumn> _columns(WidgetTester tester) {
  return tester.widgetList<SideColumn>(find.byType(SideColumn));
}

Iterable<AutoSizeText> _scores(WidgetTester tester) {
  return tester.widgetList<AutoSizeText>(find.byKey(_scoreKey));
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

      testWidgets('renders the player names on each side', (tester) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byType(PlayerNameDisplay), findsNWidgets(2));
      });

      testWidgets('renders a break text on each side', (tester) async {
        await tester.pumpWidget(_host(makeMatch()));

        expect(find.byKey(_breakKey), findsNWidgets(2));
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
          _host(makeStraightPoolMatch()),
        );

        expect(find.byType(StraightPoolStats), findsNothing);
      });
    });

    group('playing', () {
      testWidgets('renders a score text on each side', (tester) async {
        await tester.pumpWidget(_host(_playingMatch()));

        expect(find.byKey(_scoreKey), findsNWidgets(2));
        expect(find.byKey(_breakKey), findsNothing);
      });

      testWidgets('marks the breaker side columns', (tester) async {
        await tester.pumpWidget(_host(_playingMatch()));

        final columns = _columns(tester);
        expect(columns.first.isBreaker, isTrue);
        expect(columns.last.isBreaker, isFalse);
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

        final columns = _columns(tester);
        expect(columns.first.isWinner, isTrue);
        expect(columns.first.isLoser, isFalse);
        expect(columns.last.isWinner, isFalse);
        expect(columns.last.isLoser, isTrue);
      });

      testWidgets('renders straight pool stats', (tester) async {
        final match = makeStraightPoolMatch().copyWith(
          status: MatchStatus.finished,
        );
        await tester.pumpWidget(_host(match));

        expect(find.byType(StraightPoolStats), findsNWidgets(2));
      });

      testWidgets('clamps the stats innings to the effective innings limit', (
        tester,
      ) async {
        final match = makeStraightPoolMatch(
          inningsLimit: 5,
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
    testWidgets('tapping a side when created selects the breaker', (
      tester,
    ) async {
      await tester.pumpWidget(_host(makeMatch()));

      await tester.tap(find.byType(SideColumn).first);
      await tester.pump();

      expect(find.byKey(_scoreKey), findsNWidgets(2));
      expect(find.byKey(_breakKey), findsNothing);
    });

    testWidgets('tapping a side in play increments that side', (tester) async {
      await tester.pumpWidget(_host(_playingMatch()));

      await tester.tap(find.byType(SideColumn).first);
      await tester.pump();

      final scores = _scores(tester);
      expect(scores.first.data, '1');
      expect(scores.last.data, '0');
    });

    testWidgets('non-straight-pool sides are tappable while playing', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_playingMatch()));

      final columns = _columns(tester);
      expect(columns.first.onTap, isNotNull);
      expect(columns.last.onTap, isNotNull);
    });

    testWidgets('straight-pool sides are not tappable while playing', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_playingSPMatch()));

      final columns = _columns(tester);
      expect(columns.first.onTap, isNull);
      expect(columns.last.onTap, isNull);
    });

    testWidgets('finished sides are not tappable', (tester) async {
      final match = makeMatch().copyWith(
        status: MatchStatus.finished,
        winnerIndex: 0,
      );
      await tester.pumpWidget(_host(match));

      final columns = _columns(tester);
      expect(columns.first.onTap, isNull);
      expect(columns.last.onTap, isNull);
    });

    testWidgets('tapping a straight-pool side does nothing', (tester) async {
      await tester.pumpWidget(_host(_playingSPMatch()));

      await tester.tap(find.byType(SideColumn).first);
      await tester.pump();

      final scores = _scores(tester);
      expect(scores.first.data, '0');
      expect(scores.last.data, '0');
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

  group('responsive layout', () {
    testWidgets('uses a Row above the compact breakpoint', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.compact + 100);
      await tester.pumpWidget(_host(makeMatch()));

      final columns = find.byType(SideColumn);
      final a = tester.getTopLeft(columns.at(0));
      final b = tester.getTopLeft(columns.at(1));

      expect(a.dy, b.dy); // same row
      expect(b.dx, greaterThan(a.dx));
    });

    testWidgets('stacks in a Column below the compact breakpoint', (
      tester,
    ) async {
      _setWidth(tester, LayoutBreakpoints.compact - 100);
      await tester.pumpWidget(_host(makeMatch()));

      final columns = find.byType(SideColumn);
      final a = tester.getTopLeft(columns.at(0));
      final b = tester.getTopLeft(columns.at(1));

      expect(b.dy, greaterThan(a.dy)); // stacked
    });
  });
}
