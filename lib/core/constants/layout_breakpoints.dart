/// Static-only holder for responsive layout breakpoints.
class LayoutBreakpoints {
  new _();

  /// Below this width, layouts stack into a single column.
  static const double compact = 600;

  /// Below this width, wide side-by-side layouts stack vertically.
  static const double wide = 800;
}
