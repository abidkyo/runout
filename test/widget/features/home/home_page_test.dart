import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/app_strings.dart';
import 'package:runout/core/settings/app_settings.dart';
import 'package:runout/data/repositories/match_repository.dart';
import 'package:runout/data/repositories/player_repository.dart';
import 'package:runout/data/repositories/settings_repository.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/history/match_history_page.dart';
import 'package:runout/features/home/home_page.dart';
import 'package:runout/features/match/match_page.dart';
import 'package:runout/features/match_setup/match_setup_page.dart';
import 'package:runout/features/settings/settings_notifier.dart';
import 'package:runout/features/settings/settings_page.dart';
import 'package:runout/shared/widgets/match_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../unit/helpers/factories.dart';
import '../../../unit/helpers/fake_repositories.dart';

// ---------------------------------------------------------------------------

final DateTime _base = DateTime(2026);

Widget _host({MatchRepository? repository}) {
  return MultiProvider(
    providers: [
      Provider<MatchRepository>.value(
        value: repository ?? FakeMatchRepository(),
      ),
      Provider<PlayerRepository>.value(value: FakePlayerRepository()),
      ChangeNotifierProvider<SettingsNotifier>(
        create: (_) => SettingsNotifier(
          SettingsRepository(SharedPreferencesAsync()),
          initialSettings: AppSettings.defaults,
        ),
      ),
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

Match _playingMatch() {
  return makeMatch().copyWith(
    id: 'playing',
    status: MatchStatus.playing,
    startedAt: _base,
    currentSideIndex: 0,
  );
}

List<Match> _finishedMatches(int count) {
  return [
    for (var i = 0; i < count; i++)
      makeMatch().copyWith(
        id: 'finished-$i',
        status: MatchStatus.finished,
        sides: [makeSide('0', score: 10), makeSide('1', score: 5)],
        startedAt: _base.add(Duration(days: i)),
        endedAt: _base.add(Duration(days: i, hours: 1)),
        currentSideIndex: 0,
        winnerIndex: 0,
      ),
  ];
}

// ---------------------------------------------------------------------------

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  group('layout', () {
    testWidgets('wide layout uses the sidebar and no app bar', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(
        _host(repository: FakeMatchRepository(matches: [_playingMatch()])),
      );

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

    testWidgets('renders a three-player match', (tester) async {
      _setSize(tester, const Size(1200, 1600));
      final match = makeMatch(sideCount: 3).copyWith(
        id: 'three-player',
        status: MatchStatus.playing,
        startedAt: _base,
        currentSideIndex: 0,
      );
      await tester.pumpWidget(
        _host(repository: FakeMatchRepository(matches: [match])),
      );

      expect(find.text('Player-0'), findsOneWidget);
      expect(find.text('Player-1'), findsOneWidget);
      expect(find.text('Player-2'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('new match opens match setup page', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(_host());

      await tester.tap(find.text('New Match'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchSetupPage), findsOneWidget);
    });

    testWidgets('tap on hero card opens match setup page', (tester) async {
      _setSize(tester, const Size(1200, 900));
      await tester.pumpWidget(_host());

      final hero = find.ancestor(
        of: find.text('New Match'),
        matching: find.byType(Card),
      );

      await tester.tap(hero);
      await tester.pumpAndSettle();

      expect(find.byType(MatchSetupPage), findsOneWidget);
    });

    testWidgets('continue opens the match page', (tester) async {
      _setSize(tester, const Size(1200, 1200));
      await tester.pumpWidget(
        _host(repository: FakeMatchRepository(matches: [_playingMatch()])),
      );

      await tester.ensureVisible(find.text('Continue').first);
      await tester.tap(find.text('Continue').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MatchPage), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);

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

    testWidgets('players tab shows a placeholder', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_host());

      await tester.tap(find.byIcon(Icons.people_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Player management is coming soon.'), findsOneWidget);
    });

    testWidgets('settings tab shows the settings page', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_host());

      await tester.tap(find.byIcon(Icons.settings_outlined).last);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
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
        _host(repository: FakeMatchRepository(matches: _finishedMatches(1))),
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
        _host(repository: FakeMatchRepository(matches: _finishedMatches(12))),
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
