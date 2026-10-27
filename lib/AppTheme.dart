import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AppColors.dart';

/// Light + dark themes. Everything screen-level reads surfaces and text colors
/// from the [ColorScheme] so both modes stay consistent automatically.
class AppTheme {
  AppTheme._();

  /// Corner radius used by cards and sheets.
  static const double radius = 22;

  static const ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.teal,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCEDF0),
    onPrimaryContainer: Color(0xFF0C3B45),
    secondary: AppColors.gold,
    onSecondary: Color(0xFF32230A),
    surface: Colors.white,
    onSurface: Color(0xFF0E1B26),
    onSurfaceVariant: Color(0xFF66767F),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFAFBFC),
    surfaceContainer: Color(0xFFF1F4F7),
    surfaceContainerHigh: Color(0xFFE9EEF2),
    surfaceContainerHighest: Color(0xFFE2E9EE),
    outline: Color(0xFFB8C4CC),
    outlineVariant: Color(0xFFE3EAEF),
    error: AppColors.danger,
    onError: Colors.white,
  );

  static const ColorScheme _darkScheme = ColorScheme.dark(
    primary: Color(0xFF4FC3CE),
    onPrimary: Color(0xFF06252B),
    primaryContainer: Color(0xFF143C45),
    onPrimaryContainer: Color(0xFFCDECF0),
    secondary: AppColors.goldLight,
    onSecondary: Color(0xFF2A1C06),
    surface: Color(0xFF121D27),
    onSurface: Color(0xFFECF2F6),
    onSurfaceVariant: Color(0xFF93A4AF),
    surfaceContainerLowest: Color(0xFF0A121A),
    surfaceContainerLow: Color(0xFF101A23),
    surfaceContainer: Color(0xFF16222D),
    surfaceContainerHigh: Color(0xFF1C2A35),
    surfaceContainerHighest: Color(0xFF23323E),
    outline: Color(0xFF46565F),
    outlineVariant: Color(0xFF263440),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF3A0B07),
  );

  static ThemeData get light => _build(_lightScheme, const Color(0xFFF4F6F9));
  static ThemeData get dark => _build(_darkScheme, const Color(0xFF0A121A));

  static ThemeData _build(ColorScheme cs, Color scaffold) {
    final base = ThemeData(useMaterial3: true, colorScheme: cs);
    final isDark = cs.brightness == Brightness.dark;

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: base.textTheme
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface)
          .copyWith(
            displaySmall: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: cs.onSurface,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: cs.onSurface,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            titleMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            bodyLarge: TextStyle(fontSize: 15, color: cs.onSurface),
            bodyMedium: TextStyle(fontSize: 14, color: cs.onSurface),
            bodySmall: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: cs.onSurface,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? cs.surfaceContainerHighest : AppColors.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
