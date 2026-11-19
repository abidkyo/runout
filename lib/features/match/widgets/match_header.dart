import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match_config.dart';
import 'package:runout/features/match/widgets/match_timer.dart';

/// In-page header for the match scoreboard.
///
/// Shows the game, the race target (and the innings limit for straight pool)
/// and the elapsed match time.
class MatchHeader extends StatelessWidget {
  const new({required this.config, super.key});

  final MatchConfig config;

  String get _target {
    final raceTo = 'Race to ${config.raceTo}';
    if (config.gameType != GameType.straightPool) return raceTo;
    return '$raceTo / ${config.inningsLimit} innings';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.gameType.displayName,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: isCompact ? 22 : 24,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _target,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const MatchTimer(),
      ],
    );
  }
}
