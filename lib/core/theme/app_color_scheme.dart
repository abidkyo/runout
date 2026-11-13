import 'package:material_ui/material_ui.dart';

/// App semantic colors, extending the Material [ColorScheme].
///
/// Import this file where the getters are used; extensions do not resolve
/// transitively.
extension AppColorScheme on ColorScheme {
  Color get screenTitle => primary;

  Color get appTitle => primary;
  Color get appSubtitle => onSurfaceVariant;

  Color get prompt => primary;

  Color get playerName => tertiary;

  Color get sidesFill => secondaryContainer;
  Color get sidesBorder => primary;

  Color get dialogBody => onSurfaceVariant;

  Color get fieldLabel => onSurfaceVariant;
  Color get sectionLabel => onSurfaceVariant;

  Color get timer => onSurfaceVariant;
  Color get stats => onSurfaceVariant;

  Color get ballSelectedBackground => primary;
  Color get ballSelectedForeground => onPrimary;
}
