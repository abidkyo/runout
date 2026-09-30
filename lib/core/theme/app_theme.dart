import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation.
  // AppTheme is a static-only holder for theme definitions.
  new _();

  static const Color _seed = Colors.blue;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

/// App-specific text styles derived from the Material text theme.
extension AppTextTheme on TextTheme {
  /// `titleMedium` shape at `titleLarge` size.
  TextStyle get titleMediumLarge => titleMedium!.copyWith(
    fontSize: titleLarge?.fontSize,
  );
}
