/// Centralized opacity values used throughout the app.
///
/// Keeping opacity values as named constants prevents magic numbers and
/// makes it easy to adjust the overall visual density in one place.
abstract class AppAlpha {
  // ── Background & surface ──────────────────────────────────────────────
  /// AppBar background opacity.
  static const double barBg = 0.02;

  /// Footer navigation bar background opacity.
  static const double footerBg = 0.95;

  /// Footer border opacity.
  static const double footerBorder = 0.10;

  /// Input field border opacity.
  static const double inputBorder = 0.15;

  /// Divider line opacity.
  static const double divider = 0.12;

  /// Card / chip background tint opacity.
  static const double iconChipBg = 0.12;

  /// Glow/shadow effect opacity (e.g., for CTA buttons).
  static const double glowLight = 0.35;

  /// Dimmed / secondary text opacity (muted labels, footnotes).
  static const double dimmedText = 0.50;

  /// Selected tile / card tint background opacity.
  static const double selectedTintBg = 0.10;
}
