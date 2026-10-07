import 'package:flutter/material.dart';
import 'package:runout/core/theme/app_text_theme.dart';

/// A two-button confirmation dialog.
///
/// Returns `true` if the user confirmed, `false` otherwise — including
/// barrier dismiss, which is treated as cancel.
class ConfirmDialog extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// When true, the confirm button uses the theme's error color to signal
  /// an irreversible or lossy action (leave, delete, discard).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      titleTextStyle: Theme.of(context).textTheme.titleLargeSolid,
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(12),
            foregroundColor: destructive ? colorScheme.error : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Shows a [ConfirmDialog] and returns whether the user confirmed.
///
/// Barrier dismiss resolves to `false`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}
