import 'package:material_ui/material_ui.dart';

/// App color presets used to seed the Material color scheme.
enum AppColor {
  blue(Color(0xFF1F5F8B)),
  green(Color(0xFF0E7A5F));

  new(this.seed);

  /// Seed used to generate both the light and dark color schemes.
  final Color seed;

  String get label => switch (this) {
    .blue => 'Blue',
    .green => 'Green',
  };
}
