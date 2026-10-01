import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side, with affiliation shown above the name.
///
/// Affiliation is only shown for the first player in the side.
class PlayerNameDisplay extends StatelessWidget {
  const new({required this.side, super.key});

  final MatchSide side;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < side.players.length; i++)
          _PlayerLine(
            name: side.players[i].fullName,
            affiliation: i == 0 ? side.players[i].affiliation : null,
          ),
      ],
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
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12 * 1.75,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 12 * 2.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
