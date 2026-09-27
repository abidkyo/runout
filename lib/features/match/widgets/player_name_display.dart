import 'package:flutter/material.dart';
import 'package:runout/domain/models/match_side.dart';

/// Displays the players of a side, with country shown above the name.
///
/// In doubles mode, [showCountry] is false to save space for two names.
class PlayerNameDisplay extends StatelessWidget {
  const new({
    required this.side,
    required this.showCountry,
    super.key,
  });

  final MatchSide side;
  final bool showCountry;

  @override
  Widget build(BuildContext context) {
    return Column(
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
