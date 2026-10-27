import 'package:flutter/material.dart';

/// Brand + semantic colors.
///
/// Surfaces and text colors are NOT here on purpose: those come from the
/// active [ColorScheme] so the whole app works in light and dark mode.
/// Use `context.cs.surface`, `context.cs.onSurfaceVariant`, and friends.
class AppColors {
  AppColors._();

  // --- Brand ---------------------------------------------------------------
  static const Color ink = Color(0xFF0B1B2B);
  static const Color navy = Color(0xFF12314C);
  static const Color teal = Color(0xFF1E6E7E);
  static const Color aqua = Color(0xFF35A3A8);
  static const Color gold = Color(0xFFD9A54C);
  static const Color goldLight = Color(0xFFF0C987);

  /// Primary brand color used for buttons, active states, focus rings.
  static const Color primary = teal;

  // --- Semantic ------------------------------------------------------------
  static const Color success = Color(0xFF2BA86A);
  static const Color danger = Color(0xFFE4574E);
  static const Color warning = Color(0xFFE2B03C);

  // --- Gradients -----------------------------------------------------------
  /// The hero gradient on the balance card.
  static const List<Color> heroGradient = [
    Color(0xFF123047),
    Color(0xFF17566A),
    Color(0xFF1C7E85),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFE2B45B),
    Color(0xFFC98F38),
  ];

  // --- Category palette ----------------------------------------------------
  static const Color catFood = Color(0xFFF2994A);
  static const Color catTransport = Color(0xFF3B9BE0);
  static const Color catShopping = Color(0xFFB469D8);
  static const Color catInvest = Color(0xFF2BA86A);
  static const Color catSubscription = Color(0xFF5BC8D8);
  static const Color catOther = Color(0xFF8E9BA6);
}

/// Shorthand for the active color scheme: `context.cs.surface`.
extension ColorSchemeX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
