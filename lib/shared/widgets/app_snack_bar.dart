import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_constants.dart';

/// Shows a single app-wide snackbar, replacing any current one.
///
/// The close icon is only shown when there is no action; an action already
/// gives the user a way to dismiss.
void showAppSnackBar(
  String message, {
  SnackBarAction? action,
}) {
  final messenger = AppConstants.scaffoldMessengerKey.currentState;
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: action == null,
        action: action,
      ),
    );
}
