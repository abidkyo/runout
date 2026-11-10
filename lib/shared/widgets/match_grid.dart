import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/shared/widgets/match_card.dart';

/// Lays out [MatchCard]s in two columns on wide widths and one otherwise.
class MatchGrid extends StatelessWidget {
  const new({
    required this.matches,
    super.key,
    this.onTap,
  });

  /// Matches to display, in order.
  final List<Match> matches;

  /// Called when a card is tapped. When null, cards are display-only.
  final ValueChanged<Match>? onTap;

  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= LayoutBreakpoints.wide;
        final columns = isWide ? 2 : 1;
        final cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - _spacing) / 2;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final match in matches)
              SizedBox(
                width: cardWidth,
                child: MatchCard(
                  match: match,
                  onTap: onTap == null ? null : () => onTap!(match),
                ),
              ),
          ],
        );
      },
    );
  }
}
