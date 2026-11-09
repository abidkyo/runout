import 'package:material_ui/material_ui.dart';

/// Shows a single app-wide snackbar, replacing any current one.
///
/// The close icon is only shown when there is no action; an action already
/// gives the user a way to dismiss.
void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: action == null,
        action: action,
      ),
    );
}
