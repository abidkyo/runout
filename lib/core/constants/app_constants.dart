import 'package:material_ui/material_ui.dart';

/// App-wide constants shared by the app shell and tests.
abstract final class AppConstants {
  static const String appName = 'Runout';
  static const String appTitle = 'RUNOUT';
  static const String appSubtitle = 'Play · Score · Enjoy';
  static const String appDescription =
      'A billiard scoring app for 8-ball, 9-ball, 10-ball, and straight pool.';

  /// Displayed version; keep in sync with `pubspec.yaml`.
  static const String appVersion = '0.1.0';
  static const String legalese = '© 2026 abidkyo. All rights reserved.';
  static const String portfolioSite = 'abidkyo.github.io';

  // Asset name for the runout icon.
  static const String iconPath = 'assets/icons/runout-icon.svg';

  /// Messenger used by showAppSnackBar so it does not need a context.
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
