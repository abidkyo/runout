import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/features/match/widgets/match_title.dart';

import '../../../unit/helpers/factories.dart';

// ---------------------------------------------------------------------------

/// Pumps [MatchTitle] inside an AppBar at the given width so the
/// internal LayoutBuilder sees a realistic title slot.
Future<void> _pumpTitle(
  WidgetTester tester,
  MatchConfig config,
  double width,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: MatchTitle(config: config),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('MatchTitle — non-straight-pool', () {
    final config = makeConfig(gameType: GameType.tenBall, raceTo: 999);

    testWidgets('wide: full display name and "Race to"', (tester) async {
      await _pumpTitle(tester, config, 281);

      expect(find.text('10 Ball – Race to 999'), findsOneWidget);
    });

    testWidgets('narrow: display name and bare target', (tester) async {
      await _pumpTitle(tester, config, 280);

      expect(find.text('10 Ball – 999'), findsOneWidget);
    });
  });

  group('MatchTitle — straight pool', () {
    final config = makeStraightPoolConfig(raceTo: 999, inningsLimit: 99);

    testWidgets('wide: full display name, "Race to", innings', (tester) async {
      await _pumpTitle(tester, config, 541);

      expect(
        find.text('Straight Pool – Race to 999 / 99 innings'),
        findsOneWidget,
      );
    });

    testWidgets('medium: short name, "Race to", innings', (tester) async {
      await _pumpTitle(tester, config, 421);

      expect(find.text('14.1 – Race to 999 / 99 innings'), findsOneWidget);
    });

    testWidgets('narrow: short name, bare target, innings', (tester) async {
      await _pumpTitle(tester, config, 420);

      expect(find.text('14.1 – 999 / 99'), findsOneWidget);
    });
  });
}
