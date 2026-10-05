import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
import 'package:runout/features/match/match_notifier.dart';
import 'package:runout/features/match/widgets/new_rack_picker_dialog.dart';
import 'package:runout/features/match/widgets/remaining_picker_dialog.dart';

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

  static const double _iconSize = 28;

  void _maybeNotify(BuildContext context, MatchNotifier notifier) {
    if (notifier.notifyExtension) {
      notifier.notifyExtension = false;
      final limit = notifier.match.effectiveInningsLimit;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tied — 5 more innings (total $limit innings)'),
            showCloseIcon: true,
          ),
        );
      return;
    }

    if (notifier.notifyThreeFouls) {
      notifier.notifyThreeFouls = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Three fouls — 15 point penalty, re-rack'),
            showCloseIcon: true,
          ),
        );
      return;
    }
  }

  void _endVisit(BuildContext context, MatchNotifier notifier) {
    notifier.endVisit();
    _maybeNotify(context, notifier);
  }

  Future<void> _pickRemaining(
    BuildContext context,
    MatchNotifier notifier,
  ) async {
    final match = notifier.match;

    final result = await showDialog<RemainingResult>(
      context: context,
      builder: (_) => RemainingPickerDialog(
        remaining: match.remaining,
        showBreakFoul: match.isOpeningBreak,
      ),
    );
    if (result == null) return;

    notifier.scoreRemaining(
      result.remaining,
      keepsTurn: result.keepsTurn,
      foul: result.foul,
    );

    if (!context.mounted) return;
    _maybeNotify(context, notifier);
  }

  Future<void> _pickRack(BuildContext context, MatchNotifier notifier) async {
    final remaining = await showDialog<int>(
      context: context,
      builder: (_) => const NewRackPickerDialog(),
    );
    if (remaining == null) return;
    notifier.newRack(remaining);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MatchNotifier>();
    final match = notifier.match;

    final isStraightPool = match.config.gameType == GameType.straightPool;
    final isPlaying = match.status == MatchStatus.playing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                iconSize: _iconSize,
                tooltip: 'Undo',
                onPressed: notifier.canUndo ? notifier.undo : null,
                disabledColor: Colors.transparent,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.redo),
                iconSize: _iconSize,
                tooltip: 'Redo',
                onPressed: notifier.canRedo ? notifier.redo : null,
                disabledColor: Colors.transparent,
              ),
            ],
          ),
          if (isStraightPool)
            Visibility(
              visible: isPlaying,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    iconSize: _iconSize + 4,
                    tooltip: 'End visit',
                    onPressed: () => _endVisit(context, notifier),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => _pickRemaining(context, notifier),
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 12 * 1.5),
                    ),
                    child: Text('${match.remaining}'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.change_history),
                    iconSize: _iconSize + 4,
                    tooltip: 'New rack',
                    onPressed: () => notifier.newRack(1),
                    onLongPress: () => _pickRack(context, notifier),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.replay),
                iconSize: _iconSize,
                tooltip: 'Back to setup',
                onPressed: onRestart,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                iconSize: _iconSize,
                tooltip: 'Exit to home',
                onPressed: onExit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
