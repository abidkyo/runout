import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_strings.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/history/match_history_page.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/shared/widgets/match_card.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

Widget _host({MatchRepository? repository}) {
  return MultiProvider(
    providers: [
      Provider<MatchRepository>.value(
        value: repository ?? MatchRepository(),
      ),
      Provider<PlayerRepository>(create: (_) => PlayerRepository()),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void _setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

List<Match> _finishedMatches(int count) {
  return [
    for (var i = 0; i < count; i++)
      makeMatch().copyWith(
        id: 'finished-$i',
        status: MatchStatus.finished,
        scores: const [10, 5],
        startedAt: _base.add(Duration(days: i)),
        endedAt: _base.add(Duration(days: i, hours: 1)),
        currentBreakerIndex: 0,
        winnerIndex: 0,
      ),
  ];
}

// ---------------------------------------------------------------------------

void main() {
  group('layout', () {
    testWidgets('wide layout uses the sidebar and no app bar', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(_host());

      expect(find.text(AppStrings.title), findsOneWidget);
      expect(find.text(AppStrings.subtitle), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Continue Matches'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('compact layout uses the app bar and navbar', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_host());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(AppStrings.title), findsOneWidget);
      expect(find.text(AppStrings.subtitle), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('renders the three-player mock match', (tester) async {
      _setSize(tester, const Size(1200, 1600));
      await tester.pumpWidget(_host());

      expect(find.text('Efren Reyes'), findsNWidgets(2));
      expect(find.text("Ronnie O'Sullivan"), findsNWidgets(2));
      expect(find.text('Jasmin Ouschan'), findsNWidgets(2));
    });
  });

  group('navigation', () {
    testWidgets('new match opens singles setup', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(_host());

      await tester.tap(find.text('New Match'));
      await tester.pumpAndSettle();

      final page = tester.widget<MatchSetupPage>(
        find.byType(MatchSetupPage),
      );
      expect(page.mode, MatchMode.singles);
    });

    testWidgets('continue opens the match page', (tester) async {
      _setSize(tester, const Size(1200, 1200));
      await tester.pumpWidget(_host());

      await tester.ensureVisible(find.text('Continue').first);
      await tester.tap(find.text('Continue').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MatchPage), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('see all switches to the matches tab', (tester) async {
      _setSize(tester, const Size(1200, 1600));
      await tester.pumpWidget(_host());

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchHistoryPage), findsOneWidget);
      expect(find.text('Match History'), findsOneWidget);
    });

    testWidgets('players and settings tabs show placeholders', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_host());

      await tester.tap(find.byIcon(Icons.people_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Player management is coming soon.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined).last);
      await tester.pumpAndSettle();
      expect(find.text('Settings are coming soon.'), findsOneWidget);
    });

    testWidgets('sidebar switches tabs on wide layouts', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(_host());

      await tester.tap(find.text('Players'));
      await tester.pumpAndSettle();

      expect(find.text('Player management is coming soon.'), findsOneWidget);
    });
  });

  group('continue section', () {
    testWidgets('is hidden when no match is playing', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(
        _host(repository: MatchRepository(matches: _finishedMatches(1))),
      );

      expect(find.text('Continue Matches'), findsNothing);
      expect(find.text('No matches in progress'), findsNothing);
      expect(find.byType(MatchCard), findsOneWidget);
    });
  });

  group('recent matches', () {
    testWidgets('caps the home list at ten', (tester) async {
      _setSize(tester, const Size(1200, 2000));
      await tester.pumpWidget(
        _host(repository: MatchRepository(matches: _finishedMatches(12))),
      );

      expect(find.byType(MatchCard), findsNWidgets(10));

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchCard), findsNWidgets(12));
    });
  });

  group('dynamic type', () {
    testWidgets('home does not overflow at 1.5x and 2x text scale', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));

      for (final scale in [1.5, 2.0]) {
        _setTextScale(tester, scale);
        await tester.pumpWidget(_host());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });
  });
}
