import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/domain/enums/game_type.dart';
import 'package:runout/domain/models/match.dart';
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

  static const double _iconSize = 28;

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
              key: const ValueKey('straight-pool-actions-visibility'),
              visible: isPlaying,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: const StraightPoolActions(),
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
