import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runout/features/match/match_notifier.dart';

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
    final notifier = context.watch<MatchNotifier>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: notifier.canUndo ? notifier.undo : null,
                disabledColor: Colors.transparent,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
                onPressed: notifier.canRedo ? notifier.redo : null,
                disabledColor: Colors.transparent,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.replay),
                tooltip: 'Back to setup',
                onPressed: onRestart,
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
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
