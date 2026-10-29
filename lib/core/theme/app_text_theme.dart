import 'package:material_ui/material_ui.dart';

/// App typography, extending the Material [TextTheme].
///
/// Highlighted text styles are Inter and use explicit [FontWeight] values.
/// Import this file where the extension is used; extensions do not resolve
/// transitively.
extension AppTextTheme on TextTheme {
  /// Bounds for the auto-sized match score.
  static const double scoreMinFontSize = 24;
  static const double scoreMaxFontSize = 288;

  /// Family registered in `pubspec.yaml`.
  static const String fontFamily = 'Inter';

  /// Large title at medium weight.
  TextStyle get titleLargeSolid =>
      titleLarge!.copyWith(fontWeight: FontWeight.w500);

  TextStyle get screenTitle => titleLargeSolid;
  TextStyle get modeTitle => titleLargeSolid;

  TextStyle get dialogTitle => titleLargeSolid;
  TextStyle get dialogBody => bodyLarge!;

  TextStyle get playerName => titleLargeSolid;
  TextStyle get playerClub => titleMedium!;

  TextStyle get prompt => titleLargeSolid;

  // dropdown menu and text field
  TextStyle get fieldText => titleMedium!;
  TextStyle get fieldLabel => labelMedium!;
  TextStyle get fieldValue => labelLarge!;

  TextStyle get sectionLabel => labelLarge!;

  TextStyle get ballLabel => labelLarge!.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get remainingLabel => titleLarge!.copyWith(
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get score => titleMedium!.copyWith(
    fontSize: scoreMaxFontSize,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get stepperValue => titleMedium!.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get timer => bodyLarge!.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get stats => bodyMedium!.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
