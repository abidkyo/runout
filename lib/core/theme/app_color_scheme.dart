import 'package:material_ui/material_ui.dart';

/// App semantic colors, extending the Material [ColorScheme].
///
/// Import this file where the getters are used; extensions do not resolve
/// transitively.
extension AppColorScheme on ColorScheme {
  Color get appTitle => primary;
  Color get appSubtitle => onSurfaceVariant;

  Color get playerName => tertiary;

  Color get dialogBody => onSurfaceVariant;
}
