import 'package:material_ui/material_ui.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

/// One side's column on the match page, presented as a single card:
/// names on top, [child] filling below.
///
/// - [isBreaker] draws a primary-colored border.
/// - [isWinner] draws a primary-colored border and fills the card with
///   the primary container color.
/// - [isLoser] dims the whole card.
///
/// [isBreaker] and [isWinner] are independent: the winner is not
/// necessarily the breaker, and a side can be the breaker without being
/// the winner. When both are true the border is drawn once (same color).
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.child,
    this.stats,
    this.isWinner = false,
    this.isLoser = false,
    this.isBreaker = false,
    super.key,
  });

  final MatchSide side;
  final Widget child;
  final Widget? stats;

  final bool isWinner;
  final bool isLoser;
  final bool isBreaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateLabel = isWinner
        ? 'Winner'
        : isBreaker
        ? 'Breaking'
        : isLoser
        ? 'Loser'
        : null;

    return Semantics(
      container: true,
      label: stateLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: isWinner ? theme.colorScheme.primaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Always width 4, transparent when neither breaker nor winner, so the
          // card's content box stays the same size with/without border.
          side: BorderSide(
            color: isBreaker || isWinner
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 4,
          ),
        ),
        // Opacity with value 1.0 is a no-op in Flutter (no layer is created),
        // so this is free when not dimmed.
        child: Opacity(
          opacity: isLoser ? 0.5 : 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: .stretch,
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
      ),
    );
  }
}
