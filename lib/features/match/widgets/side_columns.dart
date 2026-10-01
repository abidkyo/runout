import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

/// One side's column on the match page, presented as a single card:
/// names on top, [child] filling below.
///
/// When [isWinner] is true, the card is outlined in the primary color.
/// When [isDimmed] is true, the whole card is dimmed.
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.child,
    this.isWinner = false,
    this.isDimmed = false,
    this.isBreaker = false,
    super.key,
  });

  final MatchSide side;
  final Widget child;
  final bool isWinner;
  final bool isDimmed;
  final bool isBreaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isWinner ? theme.colorScheme.primary : Colors.transparent,
          width: 4,
        ),
      ),
      child: Opacity(
        opacity: isDimmed ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              PlayerNameDisplay(
                side: side,
                isWinner: isWinner,
                isBreaker: isBreaker,
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
