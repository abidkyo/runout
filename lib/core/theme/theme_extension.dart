import 'package:material_ui/material_ui.dart';

/// Theme shortcuts for widgets.
extension ThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}
