import 'package:flutter/material.dart';

/// Smart Campus design tokens — dark-first.
class AppTheme {
  // Surfaces
  static const bg = Color(0xFF0B0B0F);
  static const surface = Color(0xFF1A1A22);
  static const surfaceVariant = Color(0xFF2A2A35);

  // Brand
  static const primary = Color(0xFFA78BFA); // lavender
  static const onPrimary = Color(0xFF0B0B0F);
  static const live = Color(0xFFEC4899); // pink
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A8A93);
  static const textMuted = Color(0xFF6B6B75);

  // Radius
  static const cardRadius = 14.0;
  static const heroRadius = 18.0;
  static const phoneShellRadius = 28.0;

  // Active bottom-nav chip behind icon
  static const navIndicator = Color(0xFF2A1E3A);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D1B69), Color(0xFF4C1D95)],
  );

  static ThemeData light({bool highContrast = false}) =>
      _build(_scheme(Brightness.light, highContrast: highContrast));
  static ThemeData dark({bool highContrast = false}) =>
      _build(_scheme(Brightness.dark, highContrast: highContrast));

  static ColorScheme _scheme(Brightness b, {bool highContrast = false}) {
    if (highContrast) {
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFE6D7FF),
        onPrimary: Colors.black,
        secondary: Color(0xFFE6D7FF),
        onSecondary: Colors.black,
        tertiary: Color(0xFFFFB1D8),
        onTertiary: Colors.black,
        error: Color(0xFFFFB4AB),
        onError: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: Color(0xFF101019),
        surfaceContainer: Color(0xFF101019),
        surfaceContainerHigh: Color(0xFF1A1A22),
        surfaceContainerHighest: Color(0xFF26262F),
        onSurfaceVariant: Color(0xFFE0E0E5),
        outline: Color(0xFFB0B0BA),
        outlineVariant: Color(0xFF8A8A93),
        primaryContainer: Color(0xFF3D2A66),
        onPrimaryContainer: Color(0xFFEAD9FF),
        tertiaryContainer: Color(0xFFB02060),
        onTertiaryContainer: Colors.white,
        secondaryContainer: Color(0xFF26262F),
        onSecondaryContainer: Colors.white,
      );
    }
    // Use the dark token palette for both — the app is dark-first.
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      tertiary: live,
      onTertiary: Colors.white,
      error: danger,
      onError: Colors.white,
      surface: bg,
      onSurface: textPrimary,
      surfaceContainerLowest: bg,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSecondary,
      outline: surfaceVariant,
      outlineVariant: textMuted,
      primaryContainer: navIndicator,
      onPrimaryContainer: primary,
      tertiaryContainer: live,
      onTertiaryContainer: Colors.white,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: textPrimary,
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        titleSmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineSmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: surfaceVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        side: BorderSide.none,
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
      ),
      dividerTheme: const DividerThemeData(color: surfaceVariant, thickness: 1),
    );
  }
}
