import 'package:flutter/material.dart';

/// App-specific text styles derived from the Material text theme.
extension AppTextTheme on TextTheme {
  /// `titleLarge` at a stronger weight.
  TextStyle get titleLargeSolid => titleLarge!.copyWith(fontWeight: .w500);
}
