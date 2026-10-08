import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/domain/models/player.dart';

/// A single fillable player slot on the setup page.
///
/// Shows either a chosen player or an empty "pick player" state.
class PlayerSlot extends StatelessWidget {
  const new({required this.player, required this.onTap, super.key});

  /// The assigned player, or null if this slot is empty.
  final Player? player;

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
                : _PlayerDisplay(player: player!),
          ),
        ),
      ),
    );
  }
}

/// Displays a chosen player, with club shown above the name.
class _PlayerDisplay extends StatelessWidget {
  const new({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.clubName ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          player.fullName,
          style: theme.textTheme.titleLargeSolid,
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
