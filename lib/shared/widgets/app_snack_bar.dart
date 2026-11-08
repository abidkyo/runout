import 'package:material_ui/material_ui.dart';

/// Shows a single app-wide snackbar, replacing any current one.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
      ),
    );
}
