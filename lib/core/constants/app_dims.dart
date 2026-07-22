/// Centralized dimension and spacing constants.
///
/// Provides all spacing, sizing, and radius values used across the UI.
/// This is the single source of truth for visual dimensions.
abstract class AppDims {
  // ── Spacing scale ──────────────────────────────────────────────────────
  static const double base = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // ── Border radius scale ────────────────────────────────────────────────
  static const double radiusCard = 18.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Sizing ─────────────────────────────────────────────────────────────
  /// Height of the bottom navigation bar (excluding safe area inset).
  static const double footerHeight = 64.0;
}
