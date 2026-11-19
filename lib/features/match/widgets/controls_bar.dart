import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/straight_pool_actions.dart';

/// Bottom bar of the match page with undo/redo and exit/restart controls.
class ControlsBar extends StatelessWidget {
  const new({
    required this.onRestart,
    required this.onExit,
    super.key,
  });

  /// Called when the user wants to return to the setup page.
  final VoidCallback onRestart;

  /// Called when the user wants to return to the home page.
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= LayoutBreakpoints.wide;
    final isCompact = width < LayoutBreakpoints.compact;

    final match = context.read<MatchNotifier>().match;
    final isStraightPool = match.config.gameType == GameType.straightPool;

    return Container(
      height: isCompact ? 65 : 77,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24,
          vertical: isCompact ? 8 : 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _UndoRedoButton(),
            if (isStraightPool && isWide) const StraightPoolActions(),
            _NavigationButton(onRestart: onRestart, onExit: onExit),
          ],
        ),
      ),
    );
  }
}

class _UndoRedoButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();

    return Row(
      children: [
        Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: notifier.canUndo,
          child: _IconLabelButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            onPressed: notifier.canUndo ? notifier.undo : null,
          ),
        ),
        Visibility(
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: notifier.canRedo,
          child: _IconLabelButton(
            icon: Icons.redo_rounded,
            label: 'Redo',
            onPressed: notifier.canRedo ? notifier.redo : null,
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const new({
    required this.onRestart,
    required this.onExit,
  });

  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconLabelButton(
          icon: Icons.tune_rounded,
          label: 'Setup',
          onPressed: onRestart,
          tooltip: 'Back to setup',
        ),
        _IconLabelButton(
          icon: Icons.home_rounded,
          label: 'Home',
          onPressed: onExit,
          tooltip: 'Exit to home',
        ),
      ],
    );
  }
}

class _IconLabelButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < LayoutBreakpoints.compact;

    final tooltip = this.tooltip;

    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: isCompact ? const Size(56, 56) : const Size(68, 60),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Icon(icon, size: 28),
          if (!isCompact)
            Flexible(
              child: Text(label, style: context.textTheme.labelMedium),
            ),
        ],
      ),
    );

    return isCompact
        ? Tooltip(message: tooltip ?? label, child: button)
        : button;
  }
}
