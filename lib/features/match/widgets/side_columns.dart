import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';
import 'package:runout/features/match/widgets/player_name_display.dart';

/// One side's column on the match page: names on top, [child] filling below.
///
/// When [isWinner] is true, a primary-colored border is drawn around the
/// column and the losing side is dimmed when [isDimmed] is true.
class SideColumn extends StatelessWidget {
  const new({
    required this.side,
    required this.showCountry,
    required this.child,
    this.isWinner = false,
    this.isDimmed = false,
    super.key,
  });

  final MatchSide side;
  final bool showCountry;
  final Widget child;
  final bool isWinner;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final column = Column(
      children: [
        PlayerNameDisplay(
          side: side,
          showCountry: showCountry,
          isWinner: isWinner,
        ),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );

    return Container(
      decoration: isWinner
          ? BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Opacity(
        opacity: isDimmed ? 0.5 : 1,
        child: column,
      ),
    );
  }
}
