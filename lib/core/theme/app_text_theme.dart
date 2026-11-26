import 'package:material_ui/material_ui.dart';

/// App typography, extending the Material [TextTheme].
///
/// Highlighted text styles are Inter and use explicit [FontWeight] values.
/// Import this file where the extension is used; extensions do not resolve
/// transitively.
extension AppTextTheme on TextTheme {
  /// Base size for the match score. The score is fitted to its card.
  static const double scoreMaxFontSize = 384;

  /// Family registered in `pubspec.yaml`.
  static const String fontFamily = 'Inter';

  TextStyle get appTitle => titleLarge!.copyWith(
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  TextStyle get appSubtitle => labelMedium!;

  TextStyle get dialogTitle => headlineSmall!.copyWith(
    fontWeight: FontWeight.w600,
  );
  TextStyle get dialogBody => bodyLarge!;

  TextStyle get score => titleMedium!.copyWith(
    fontSize: scoreMaxFontSize,
    height: 1,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
