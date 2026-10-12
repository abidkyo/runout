import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/break_format.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/match_config_panel.dart';

const ValueKey<String> _breakFormatVisibility = ValueKey(
  'break-format-visibility',
);
const ValueKey<String> _inningsVisibility = ValueKey('innings-visibility');

void main() {
  group('MatchConfigPanel — rendering', () {
    testWidgets('renders all four game-type segments', (tester) async {
      _setTabletViewport(tester);

      final (_, widget) = _host();
      await tester.pumpWidget(widget);

      expect(find.text('8 Ball'), findsOneWidget);
      expect(find.text('9 Ball'), findsOneWidget);
      expect(find.text('10 Ball'), findsOneWidget);
      expect(find.text('14.1'), findsOneWidget);
    });

    testWidgets('renders break-format segments for non-straight-pool', (
      tester,
    ) async {
      _setTabletViewport(tester);

      final (_, widget) = _host();
      await tester.pumpWidget(widget);

      expect(find.text('Winner Break'), findsOneWidget);
      expect(find.text('Alternate Break'), findsOneWidget);
    });

    testWidgets('renders the innings stepper for straight pool', (
      tester,
    ) async {
      _setTabletViewport(tester);

      final (_, widget) = _host(gameType: .straightPool);
      await tester.pumpWidget(widget);

      // The stepper's label is composed as '25 innings' for the default value.
      expect(find.text('25 innings'), findsOneWidget);
    });
  });

  group('MatchConfigPanel — visibility flags', () {
    testWidgets('break-format is visible for non-straight-pool', (
      tester,
    ) async {
      _setTabletViewport(tester);

      final (_, widget) = _host();
      await tester.pumpWidget(widget);

      final visibility = tester.widget<Visibility>(
        find.byKey(_breakFormatVisibility),
      );
      expect(visibility.visible, isTrue);
    });

    testWidgets('break-format is hidden for straight pool', (tester) async {
      _setTabletViewport(tester);

      final (_, widget) = _host(gameType: .straightPool);
      await tester.pumpWidget(widget);

      final visibility = tester.widget<Visibility>(
        find.byKey(_breakFormatVisibility),
      );
      expect(visibility.visible, isFalse);
    });

    testWidgets('innings is hidden for non-straight-pool', (tester) async {
      _setTabletViewport(tester);

      final (_, widget) = _host();
      await tester.pumpWidget(widget);

      final visibility = tester.widget<Visibility>(
        find.byKey(_inningsVisibility),
      );
      expect(visibility.visible, isFalse);
    });

    testWidgets('innings is visible for straight pool', (tester) async {
      _setTabletViewport(tester);

      final (_, widget) = _host(gameType: .straightPool);
      await tester.pumpWidget(widget);

      final visibility = tester.widget<Visibility>(
        find.byKey(_inningsVisibility),
      );
      expect(visibility.visible, isTrue);
    });
  });

  group('MatchConfigPanel — callback wiring', () {
    testWidgets('tapping 14.1 updates the notifier game type', (tester) async {
      _setTabletViewport(tester);

      final (notifier, widget) = _host();
      await tester.pumpWidget(widget);

      await tester.tap(find.text('14.1'));
      await tester.pump();

      expect(notifier.gameType, GameType.straightPool);
    });

    testWidgets('tapping Winner Break updates the notifier break format', (
      tester,
    ) async {
      _setTabletViewport(tester);

      final (notifier, widget) = _host();
      await tester.pumpWidget(widget);

      await tester.tap(find.text('Winner Break'));
      await tester.pump();

      expect(notifier.breakFormat, BreakFormat.winnerBreak);
    });
  });
}

// ---------------------------------------------------------------------------

/// MatchConfigPanel requires ~960px width; the default 800×600 test surface
/// is too narrow. Use a landscape tablet viewport.
void _setTabletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

(MatchSetupNotifier, Widget) _host({GameType gameType = GameType.eightBall}) {
  final notifier = MatchSetupNotifier(mode: MatchMode.singles)
    ..gameType = gameType;
  return (
    notifier,
    ChangeNotifierProvider<MatchSetupNotifier>.value(
      value: notifier,
      child: const MaterialApp(home: Scaffold(body: MatchConfigPanel())),
    ),
  );
}
