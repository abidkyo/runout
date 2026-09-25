import 'package:flutter/material.dart';
import 'package:runout/domain/models/player.dart';

/// A single fillable player slot on the setup page.
///
/// Shows either a chosen player or an empty "pick player" state.
class PlayerSlot extends StatelessWidget {
  const new({
    required this.player,
    required this.showCountry,
    required this.onTap,
    super.key,
  });

  /// The assigned player, or null if this slot is empty.
  final Player? player;

  /// Whether to show the player's country above the name.
  final bool showCountry;

  /// Called when the slot is tapped to pick a player.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: player == null
                ? const _EmptySlot()
                : _PlayerDisplay(
                    player: player!,
                    showCountry: showCountry,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Displays a chosen player, with an optional country line.
class _PlayerDisplay extends StatelessWidget {
  const new({
    required this.player,
    required this.showCountry,
  });

  final Player player;
  final bool showCountry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCountry)
          Text(
            player.countryCode,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          player.fullName,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Placeholder shown when a slot has no player assigned.
class _EmptySlot extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Pick player',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
