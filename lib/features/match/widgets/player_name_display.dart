import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side, with country shown above the name.
///
/// When [isWinner] is true, a trophy icon is shown next to the first name.
class PlayerNameDisplay extends StatelessWidget {
  const new({
    required this.side,
    required this.showCountry,
    this.isWinner = false,
    super.key,
  });

  final MatchSide side;
  final bool showCountry;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final names = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final player in side.players)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _PlayerLine(
              name: player.fullName,
              country: showCountry ? player.countryCode : null,
            ),
          ),
      ],
    );

    if (!isWinner) return names;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.emoji_events,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Flexible(child: names),
      ],
    );
  }
}

/// A single player line: optional country above the name.
class _PlayerLine extends StatelessWidget {
  const new({required this.name, this.country});

  final String name;
  final String? country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (country != null)
          Text(
            country!,
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
