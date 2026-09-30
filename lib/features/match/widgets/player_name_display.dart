import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side, with affiliation shown above the name.
///
/// Leading indicators:
/// - [isWinner] shows a trophy icon.
/// - [isBreaker] shows a ball icon.
class PlayerNameDisplay extends StatelessWidget {
  const new({
    required this.side,
    required this.showAffiliation,
    this.isWinner = false,
    this.isBreaker = false,
    super.key,
  });

  final MatchSide side;
  final bool showAffiliation;
  final bool isWinner;
  final bool isBreaker;

  @override
  Widget build(BuildContext context) {
    final names = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final player in side.players)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _PlayerLine(
              name: player.fullName,
              affiliation: showAffiliation ? player.affiliation : null,
            ),
          ),
      ],
    );

    if (!isWinner && !isBreaker) return names;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isWinner) const _LeadingIcon(icon: Icons.emoji_events),
        if (isBreaker) const _LeadingIcon(icon: Icons.sports_baseball),
        const SizedBox(width: 8),
        Flexible(child: names),
      ],
    );
  }
}

/// A small leading icon shown beside the player names.
class _LeadingIcon extends StatelessWidget {
  const new({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// A single player line: optional affiliation above the name.
class _PlayerLine extends StatelessWidget {
  const new({required this.name, this.affiliation});

  final String name;
  final String? affiliation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (affiliation != null)
          Text(
            affiliation!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          name,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
