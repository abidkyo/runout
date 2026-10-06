import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_text_theme.dart';

/// Asks whether to continue playing after the match goal is reached.
///
/// Pops true to continue, false to end.
class ContinuePromptDialog extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      title: const Text('Target reached'),
      content: const Text(
        'The target score is reached.\n'
        'Do you want to continue playing?',
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('End'),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
