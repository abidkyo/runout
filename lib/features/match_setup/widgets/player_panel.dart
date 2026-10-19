import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/domain/enums/match_mode.dart';
import 'package:runout/features/match_setup/match_setup_notifier.dart';
import 'package:runout/features/match_setup/widgets/player_slot.dart';

/// Player area of the setup page: one labelled block per side.
///
/// Doubles always use the wide layout, regardless of available width.
/// Otherwise the layout follows [LayoutBreakpoints.compact]:
///
/// - Wide: the sides sit side by side.
/// - Compact: the sides stack vertically.
class PlayerPanel extends StatelessWidget {
  const new({
    required this.mode,
    required this.onSlotTap,
    super.key,
  });

  final MatchMode mode;
  final void Function(int sideIndex, int slotIndex) onSlotTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < LayoutBreakpoints.compact;
        if (isCompact) {
          return Column(
            children: [
              for (var i = 0; i < mode.sideCount; i++)
                _SideBlock(
                  mode: mode,
                  sideIndex: i,
                  onSlotTap: onSlotTap,
                ),
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < mode.sideCount; i++)
              Expanded(
                child: _SideBlock(
                  mode: mode,
                  sideIndex: i,
                  onSlotTap: onSlotTap,
                ),
              ),
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

  String get _label => switch (mode) {
    MatchMode.singles => 'Player ${sideIndex + 1}',
    MatchMode.doubles => 'Team ${String.fromCharCode(sideIndex + 65)}',
    MatchMode.threePlayer => 'Player ${sideIndex + 1}',
    MatchMode.tournament => throw UnimplementedError(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final players = context.watch<MatchSetupNotifier>().players[sideIndex];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            _label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Column(
            children: [
              for (var i = 0; i < mode.playersPerSide; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: PlayerSlot(
                    player: players[i],
                    onTap: () => onSlotTap(sideIndex, i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
