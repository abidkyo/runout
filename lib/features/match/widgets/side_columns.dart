import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

/// One side's column on the match page, presented as a single card:
/// names on top, [child] filling below.
///
/// - [isBreaker] draws a primary-colored border.
/// - [isWinner] draws a primary-colored border and fills the card with
///   the primary container color.
/// - [isDimmed] dims the whole card (used for the loser).
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.child,
    this.stats,
    this.isWinner = false,
    this.isDimmed = false,
    this.isBreaker = false,
    super.key,
  });

  final MatchSide side;
  final Widget child;
  final Widget? stats;

  final bool isWinner;
  final bool isDimmed;
  final bool isBreaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      color: isWinner ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBreaker || isWinner
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 4,
        ),
      ),
      child: Opacity(
        opacity: isDimmed ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              PlayerNameDisplay(side: side),
              const SizedBox(height: 8),
              Expanded(child: child),
              if (stats != null) ...[
                const SizedBox(height: 8),
                stats!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
