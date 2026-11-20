import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';

/// One side's card on the match page, presented as a single tappable card.
///
/// [children] are laid out top-to-bottom and stretched horizontally.
/// When [onTap] is non-null, tapping anywhere on the card invokes it.
///
/// - [isBreaker] draws a primary-colored border.
/// - [isWinner] draws a primary-colored border and fills the card with
///   the secondary container color.
/// - [isLoser] dims the whole card.
///
/// [isBreaker] and [isWinner] are independent: the winner is not
/// necessarily the breaker, and a side can be the breaker without being
/// the winner. When both are true the border is drawn once (same color).
class SideCard extends StatelessWidget {
  const new({
    required this.children,
    this.onTap,
    this.isWinner = false,
    this.isLoser = false,
    this.isBreaker = false,
    super.key,
  });

  final List<Widget> children;
  final VoidCallback? onTap;

  final bool isWinner;
  final bool isLoser;
  final bool isBreaker;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    final cardColor = isWinner
        ? context.colors.secondaryContainer
        : context.colors.surfaceContainerLowest;

    final borderColor = isBreaker || isWinner
        ? context.colors.primary
        : context.colors.outlineVariant;
    final borderWidth = isCompact ? 2.0 : 4.0;

    final stateLabel = isWinner
        ? 'Winner'
        : isBreaker
        ? 'Breaking'
        : isLoser
        ? 'Loser'
        : null;

    return Semantics(
      container: true,
      button: onTap != null,
      label: stateLabel,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        // Opacity with value 1.0 is a no-op in Flutter (no layer is created),
        // so this is free when not dimmed.
        child: Opacity(
          opacity: isLoser ? 0.5 : 1,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 8 : 16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
