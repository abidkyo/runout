import 'package:material_ui/material_ui.dart';

/// App-wide constants shared by the app shell and tests.
abstract final class AppConstants {
  // Asset name for the runout icon.
  static const String iconPath = 'assets/icons/runout-icon.svg';

  /// Messenger used by showAppSnackBar so it does not need a context.
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
