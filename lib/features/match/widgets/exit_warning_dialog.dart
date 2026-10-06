import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_text_theme.dart';

/// Confirmation dialog shown before abandoning a match that is in progress.
class ExitWarningDialog extends StatelessWidget {
  const new({super.key});

  /// Shows the dialog and returns `true` if the user confirmed leaving,
  /// `false` otherwise (including barrier dismiss).
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitWarningDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      title: const Text('Leave match?'),
      content: const Text(
        'The match is still in progress.\n'
        'Are you sure you want to leave?',
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Leave'),
        ),
      ],
    );
  }
}
