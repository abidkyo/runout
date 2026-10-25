import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match_config.dart';

/// AppBar title for the match page, adapted to the available width.
///
/// Rotation games drop the innings part.
class MatchTitle extends StatelessWidget {
  const new({required this.config, super.key});

  final MatchConfig config;

  String _title(double availableWidth) {
    final game = config.gameType;
    final isSP = game == GameType.straightPool;

    if (!isSP) {
      return availableWidth > 280
          ? '${game.displayName} – Race to ${config.raceTo}'
          : '${game.displayName} – ${config.raceTo}';
    }

    final name = availableWidth > 540 ? game.displayName : game.shortName;
    final race = availableWidth > 420
        ? 'Race to ${config.raceTo}'
        : '${config.raceTo}';
    final innings = availableWidth > 420
        ? '${config.inningsLimit} innings'
        : '${config.inningsLimit}';

    return '$name – $race / $innings';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          _title(constraints.maxWidth),
          style: Theme.of(context).textTheme.titleLargeSolid,
        );
      },
    );
  }
}
