import 'package:material_ui/material_ui.dart';
import 'package:runout/core/theme/app_text_theme.dart';
import 'package:runout/core/theme/theme_extension.dart';
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, minHeight: 120),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.clubName ?? '',
          style: context.textTheme.playerClub.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          player.fullName,
          style: context.textTheme.playerName,
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
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Icon(
          Icons.add,
          size: 20,
          color: context.colors.primary,
        ),
        Text(
          'Pick player',
          style: context.textTheme.prompt.copyWith(
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }
}
