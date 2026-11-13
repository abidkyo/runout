import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/domain/models/player.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';

/// Player area of the setup page: one labelled block per side.
///
/// All modes follow [LayoutBreakpoints.compact]:
///
/// - Wide: the sides sit side by side.
/// - Compact: the sides stack vertically.
///
/// Doubles has no special case; its two slots stay vertically stacked inside
/// each side block.
class PlayerPanel extends StatelessWidget {
  const new({required this.onSlotTap, super.key});

  final void Function(int sideIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<MatchSetupNotifier>().mode;

    final sides = [
      for (var i = 0; i < mode.sideCount; i++)
        _SideBlock(
          mode: mode,
          sideIndex: i,
          onSlotTap: onSlotTap,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < LayoutBreakpoints.compact;

        return isCompact
            ? Column(
                spacing: 16,
                children: sides,
              )
            : Row(
                spacing: 16,
                children: [
                  for (final side in sides) Expanded(child: side),
                ],
              );
      },
    );
  }
}

/// One side of the match: a label above its player slots.
class _SideBlock extends StatelessWidget {
  const new({
    required this.mode,
    required this.sideIndex,
    required this.onSlotTap,
  });

  final MatchMode mode;
  final int sideIndex;
  final void Function(int sideIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    final players = context.watch<MatchSetupNotifier>().players[sideIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          mode.label(sideIndex),
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Column(
          spacing: 16,
          children: [
            for (var i = 0; i < mode.playersPerSide; i++)
              _PlayerSlot(
                key: ValueKey('player-slot-$sideIndex-$i'),
                player: players[i],
                onTap: () => onSlotTap(sideIndex, i),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single fillable player slot on the setup page.
///
/// Shows either a chosen player or an empty state.
class _PlayerSlot extends StatelessWidget {
  const new({
    required this.player,
    required this.onTap,
    super.key,
  });

  /// The assigned player, or null if this slot is empty.
  final Player? player;

  /// Called when the slot is tapped to pick a player.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final player = this.player;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: player == null
                ? const _EmptySlot()
                : _PlayerDisplay(player: player),
          ),
        ),
      ),
    );
  }
}

/// Displays a chosen player.
class _PlayerDisplay extends StatelessWidget {
  const new({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown when a slot has no player assigned.
class _EmptySlot extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Icon(Icons.add, size: 20, color: color),
        Text(
          'Select player',
          style: context.textTheme.headlineSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

extension on MatchMode {
  String label(int sideIndex) => switch (this) {
    MatchMode.singles => 'Player ${sideIndex + 1}',
    MatchMode.doubles => 'Team ${String.fromCharCode(sideIndex + 65)}',
    MatchMode.threePlayer => 'Player ${sideIndex + 1}',
  };
}
