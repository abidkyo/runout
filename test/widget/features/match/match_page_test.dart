import 'package:clock/clock.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_constants.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/constants/persistence_defaults.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_list_notifier.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match/widgets/match_header.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';
import 'package:runout/features/match/widgets/side_card.dart';
import 'package:runout/features/match/widgets/sp_buttons.dart';
import 'package:runout/features/match/widgets/sp_scoring_dialog.dart';
import 'package:runout/features/match/widgets/straight_pool_stats.dart';
import 'package:runout/shared/widgets/confirm_dialog.dart';

import '../../../unit/helpers/factories.dart';
import '../../../unit/helpers/fake_repositories.dart';

// ---------------------------------------------------------------------------

const ValueKey<String> _breakKey = ValueKey('break-text');
const ValueKey<String> _scoreKey = ValueKey('score-text');

Future<void> _pump(
  WidgetTester tester,
  Match match, {
  MatchRepository? repository,
  double width = 1000,
  double textScale = 1,
}) {
  _setSize(tester, width, 1000);
  if (textScale != 1) _setTextScale(tester, textScale);

  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<MatchRepository>.value(
          value: repository ?? FakeMatchRepository(),
        ),
        ChangeNotifierProvider<MatchListNotifier>(
          create: (ctx) => MatchListNotifier(ctx.read<MatchRepository>()),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: AppConstants.scaffoldMessengerKey,
        home: MatchPage(match: match),
      ),
    ),
  );
}

Future<void> _pumpStackedMatchPage(
  WidgetTester tester,
  Match match, {
  MatchRepository? repository,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<MatchRepository>.value(
          value: repository ?? FakeMatchRepository(),
        ),
        ChangeNotifierProvider<MatchListNotifier>(
          create: (ctx) => MatchListNotifier(ctx.read<MatchRepository>()),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: AppConstants.scaffoldMessengerKey,
        home: Scaffold(
          body: Builder(
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
  startedAt: DateTime(2026),
  currentSideIndex: 0,
);

Match _playingSPMatch() => makeStraightPoolMatch().copyWith(
  status: MatchStatus.playing,
  startedAt: DateTime(2026),
  currentSideIndex: 0,
);

Match _finishedMatch() => makeMatch().copyWith(
  status: MatchStatus.finished,
  winnerIndex: 0,
);

Match _finishedSPMatch() => makeStraightPoolMatch().copyWith(
  status: MatchStatus.finished,
  winnerIndex: 0,
);

void _setSize(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Iterable<SideCard> _cards(WidgetTester tester) {
  return tester.widgetList<SideCard>(find.byType(SideCard));
}

Iterable<Text> _scores(WidgetTester tester) {
  return tester.widgetList<Text>(find.byKey(_scoreKey));
}

// ---------------------------------------------------------------------------

void main() {
  group('rendering', () {
    group('created', () {
      testWidgets('renders the match header', (tester) async {
        await _pump(tester, makeMatch());

        expect(find.byType(MatchHeader), findsOneWidget);
      });

      testWidgets('renders one side card per side', (tester) async {
        await _pump(tester, makeMatch());

        expect(find.byType(SideCard), findsNWidgets(2));
      });

      testWidgets(
        'renders three side cards for three-player',
        (tester) async {
          await _pump(tester, makeMatch(sideCount: 3));

          expect(find.byType(SideCard), findsNWidgets(3));
        },
      );

      testWidgets('renders the player names on each side', (tester) async {
        await _pump(tester, makeMatch());

        expect(find.byType(PlayerNameDisplay), findsNWidgets(2));
      });

      testWidgets('renders a break text on each side', (tester) async {
        await _pump(tester, makeMatch());

        expect(find.byKey(_breakKey), findsNWidgets(2));
      });

      testWidgets('straight pool stats hidden for non-straight-pool games', (
        tester,
      ) async {
        await _pump(tester, makeMatch());

        expect(find.byType(StraightPoolStats), findsNothing);
      });

      testWidgets('straight pool stats hidden when created', (tester) async {
        await _pump(tester, makeStraightPoolMatch());

        expect(find.byType(StraightPoolStats), findsNothing);
      });
    });

    group('playing', () {
      testWidgets('renders a score text on each side', (tester) async {
        await _pump(tester, _playingMatch());

        expect(find.byKey(_scoreKey), findsNWidgets(2));
        expect(find.byKey(_breakKey), findsNothing);
      });

      testWidgets('marks the breaker side cards', (tester) async {
        await _pump(tester, _playingMatch());

        final cards = _cards(tester);
        expect(cards.first.isBreaker, isTrue);
        expect(cards.last.isBreaker, isFalse);
      });

      testWidgets('straight pool stats hidden for non-straight-pool games', (
        tester,
      ) async {
        await _pump(tester, _playingMatch());

        expect(find.byType(StraightPoolStats), findsNothing);
      });

      testWidgets('renders straight pool stats', (tester) async {
        await _pump(tester, _playingSPMatch());

        expect(find.byType(StraightPoolStats), findsNWidgets(2));
      });
    });

    group('finished', () {
      testWidgets('marks the winner and loser side cards', (tester) async {
        await _pump(tester, _finishedMatch());

        final cards = _cards(tester);
        expect(cards.first.isWinner, isTrue);
        expect(cards.first.isLoser, isFalse);
        expect(cards.last.isWinner, isFalse);
        expect(cards.last.isLoser, isTrue);
      });

      testWidgets('shows a trophy on the winning side', (tester) async {
        await _pump(tester, _finishedMatch());

        expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
      });

      testWidgets('renders straight pool stats', (tester) async {
        await _pump(tester, _finishedSPMatch());

        expect(find.byType(StraightPoolStats), findsNWidgets(2));
      });

      testWidgets('clamps the stats innings to the effective innings limit', (
        tester,
      ) async {
        final match = makeStraightPoolMatch(inningsLimit: 5).copyWith(
          status: MatchStatus.finished,
          sides: [makeSide('0', innings: 7), makeSide('1', innings: 2)],
        );
        await _pump(tester, match);

        final stats = tester.widgetList<StraightPoolStats>(
          find.byType(StraightPoolStats),
        );

        expect(stats.first.innings, match.config.inningsLimit);
        expect(stats.last.innings, 2);
      });
    });
  });

  group('celebration', () {
    testWidgets('celebrates when the winning rack is scored', (tester) async {
      await _pump(tester, _playingMatch());

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byType(SideCard).first);
        await tester.pump();
      }
      await tester.pump();
      await tester.pump();

      expect(find.byType(Confetti), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(Confetti), findsNothing);
    });

    testWidgets('does not celebrate an already-finished match', (
      tester,
    ) async {
      await _pump(tester, _finishedMatch());
      await tester.pump();

      expect(find.byType(Confetti), findsNothing);
    });
  });

  group('interactions', () {
    testWidgets('tapping a side when created selects the breaker', (
      tester,
    ) async {
      await _pump(tester, makeMatch());

      await tester.tap(find.byType(SideCard).first);
      await tester.pump();

      expect(find.byKey(_scoreKey), findsNWidgets(2));
      expect(find.byKey(_breakKey), findsNothing);
    });

    testWidgets('tapping a side in play increments that side', (tester) async {
      await _pump(tester, _playingMatch());

      await tester.tap(find.byType(SideCard).first);
      await tester.pump();

      final scores = _scores(tester);
      expect(scores.first.data, '1');
      expect(scores.last.data, '0');
    });

    testWidgets('tapping a straight-pool side opens the scoring dialog', (
      tester,
    ) async {
      await _pump(tester, _playingSPMatch());

      await tester.tap(find.byType(SideCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(SPScoringDialog), findsOneWidget);
    });

    testWidgets('tapping an opponent straight-pool side opens the dialog', (
      tester,
    ) async {
      await _pump(tester, _playingSPMatch());

      await tester.tap(find.byType(SideCard).last);
      await tester.pumpAndSettle();

      expect(find.byType(SPScoringDialog), findsOneWidget);
    });

    testWidgets('confirming from a side card scores the current side', (
      tester,
    ) async {
      await _pump(tester, _playingSPMatch());

      await tester.tap(find.byType(SideCard).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pump();

      await tester.tap(find.text('Next Inning'));
      await tester.pumpAndSettle();

      final cards = _cards(tester);
      expect(cards.last.isBreaker, isTrue);
      expect(find.byType(SPScoringDialog), findsNothing);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('side-card scoring works at compact width', (tester) async {
      await _pump(
        tester,
        _playingSPMatch(),
        width: LayoutBreakpoints.compact - 100,
      );

      await tester.tap(find.byType(SideCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(SPScoringDialog), findsOneWidget);
    });

    testWidgets('finished sides are not tappable', (tester) async {
      await _pump(tester, _finishedMatch());

      final cards = _cards(tester);
      expect(cards.first.onTap, isNull);
      expect(cards.last.onTap, isNull);
    });

    testWidgets('undo restores the created state', (tester) async {
      await _pump(tester, makeStraightPoolMatch());

      await tester.tap(find.byType(SideCard).first);
      await tester.pump();

      expect(find.byKey(_scoreKey), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pump();

      expect(find.byKey(_breakKey), findsNWidgets(2));
    });
  });

  group('straight-pool controls', () {
    testWidgets('shown while playing on wide width', (tester) async {
      await _pump(
        tester,
        _playingSPMatch(),
        width: LayoutBreakpoints.wide,
      );

      expect(find.byType(SPButtons), findsOneWidget);
    });

    testWidgets('hidden below wide width', (tester) async {
      await _pump(
        tester,
        _playingSPMatch(),
        width: LayoutBreakpoints.wide - 100,
      );

      expect(find.byType(SPButtons), findsNothing);
    });

    testWidgets('hidden while created', (tester) async {
      await _pump(
        tester,
        makeStraightPoolMatch(),
        width: LayoutBreakpoints.wide,
      );

      expect(find.byType(SPButtons), findsNothing);
    });

    testWidgets('hidden when finished', (tester) async {
      await _pump(
        tester,
        _finishedSPMatch(),
        width: LayoutBreakpoints.wide,
      );

      expect(find.byType(SPButtons), findsNothing);
    });
  });

  group('setup action', () {
    testWidgets('shown by default', (tester) async {
      await _pump(tester, _playingMatch());

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('hidden when not a new match', (tester) async {
      await _pump(
        tester,
        _playingMatch().copyWith(
          pausedAt: clock.now().subtract(const Duration(minutes: 5)),
        ),
      );

      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });

  group('pause and resume', () {
    testWidgets('resumes and persists a paused match', (tester) async {
      final repository = FakeMatchRepository();
      final match = _playingMatch().copyWith(
        pausedAt: clock.now().subtract(const Duration(minutes: 5)),
        totalPausedSeconds: 10,
      );

      await _pump(tester, match, repository: repository);
      await tester.pumpAndSettle();

      final saved = repository.saves.last;
      expect(saved.pausedAt, isNull);
      expect(saved.totalPausedSeconds, greaterThanOrEqualTo(310));
    });
  });

  group('leaving', () {
    testWidgets('edit setup from created pops without a dialog', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, makeMatch());

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('open match'), findsOneWidget);
    });

    testWidgets('exit from created pops to the first route', (tester) async {
      await _pumpStackedMatchPage(tester, makeMatch());

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('edit setup while playing then cancels the dialog', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Back to setup?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsOneWidget);
    });

    testWidgets('edit setup while playing then discards and pops', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Back to setup?'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(ConfirmDialog),
          matching: find.text('Discard'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('open match'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });

    testWidgets('discard from created pops to the first route', (tester) async {
      await _pumpStackedMatchPage(tester, makeMatch());

      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('discard while playing can be cancelled', (tester) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Discard match?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsOneWidget);
    });

    testWidgets('discard while playing pops to the first route', (
      tester,
    ) async {
      await _pumpStackedMatchPage(tester, _playingMatch());

      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Discard match?'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(ConfirmDialog),
          matching: find.text('Discard'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('exit while playing does not confirm and pauses', (
      tester,
    ) async {
      final repository = FakeMatchRepository();
      await _pumpStackedMatchPage(
        tester,
        _playingMatch(),
        repository: repository,
      );

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDialog), findsNothing);
      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
      expect(repository.getPlaying().single.pausedAt, isNotNull);
    });
  });

  group('persistence error', () {
    testWidgets('shows a snackbar when saving fails', (tester) async {
      await _pump(
        tester,
        _playingMatch(),
        repository: FakeMatchRepository()
          ..failSaves = PersistenceDefaults.maxAttempts,
      );

      await tester.tap(find.byType(SideCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Could not save match progress.'), findsOneWidget);
    });

    testWidgets('shows a snackbar when discard fails', (
      tester,
    ) async {
      await _pumpStackedMatchPage(
        tester,
        makeMatch(),
        repository: FakeMatchRepository()
          ..failDeletes = PersistenceDefaults.maxAttempts,
      );

      await tester.tap(find.byIcon(Icons.delete_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(MatchPage), findsNothing);
      expect(find.text('home'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Could not discard match.'), findsOneWidget);
    });
  });

  group('responsive layout', () {
    testWidgets('uses a Row above the compact breakpoint', (tester) async {
      await _pump(tester, makeMatch(), width: LayoutBreakpoints.compact + 100);

      final cards = find.byType(SideCard);
      final a = tester.getTopLeft(cards.at(0));
      final b = tester.getTopLeft(cards.at(1));

      expect(a.dy, b.dy); // same row
      expect(b.dx, greaterThan(a.dx));
    });

    testWidgets('stacks in a Column below the compact breakpoint', (
      tester,
    ) async {
      await _pump(tester, makeMatch(), width: LayoutBreakpoints.compact - 100);

      final cards = find.byType(SideCard);
      final a = tester.getTopLeft(cards.at(0));
      final b = tester.getTopLeft(cards.at(1));

      expect(b.dy, greaterThan(a.dy)); // stacked
    });

    testWidgets('fits the created state at 2x on 375 width', (tester) async {
      await _pump(
        tester,
        makeStraightPoolMatch(sideCount: 3).copyWith(
          status: MatchStatus.playing,
          currentSideIndex: 0,
        ),
        width: 375,
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('fits straight-pool controls at 2x on wide width', (
      tester,
    ) async {
      await _pump(
        tester,
        _playingSPMatch(),
        width: LayoutBreakpoints.wide,
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
