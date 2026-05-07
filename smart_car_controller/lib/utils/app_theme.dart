// ============================================================
// app_theme.dart — Futuristic cyberpunk theme (google_fonts)
// Smart AI Voice Car Controller
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ───────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF030712);
  static const Color darkSurface = Color(0xFF0D1117);
  static const Color darkCard    = Color(0xFF0F1923);
  static const Color darkBorder  = Color(0xFF1E2D3D);

  static const Color neonCyan   = Color(0xFF00D4FF);
  static const Color neonBlue   = Color(0xFF0066FF);
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonGreen  = Color(0xFF00FF88);
  static const Color neonRed    = Color(0xFFFF3366);
  static const Color neonOrange = Color(0xFFFF6B00);

  static const Color textPrimary   = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF475569);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF030712), Color(0xFF0A0F1E), Color(0xFF030B1A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F1923), Color(0xFF0D1420)],
  );

  static const LinearGradient cyanGradient =
      LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066FF)]);

  static const LinearGradient purpleGradient =
      LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)]);

  static const LinearGradient greenGradient =
      LinearGradient(colors: [Color(0xFF00FF88), Color(0xFF00D4FF)]);

  static const LinearGradient redGradient =
      LinearGradient(colors: [Color(0xFFFF3366), Color(0xFFFF6B00)]);

  // ── Shadows / Glows ───────────────────────────────────────
  static List<BoxShadow> cyanGlow([double intensity = 1.0]) => [
        BoxShadow(color: neonCyan.withValues(alpha: 0.4 * intensity),  blurRadius: 24 * intensity, spreadRadius: 2 * intensity),
        BoxShadow(color: neonCyan.withValues(alpha: 0.15 * intensity), blurRadius: 48 * intensity, spreadRadius: 4 * intensity),
      ];

  static List<BoxShadow> purpleGlow([double intensity = 1.0]) => [
        BoxShadow(color: neonPurple.withValues(alpha: 0.4 * intensity), blurRadius: 24 * intensity, spreadRadius: 2 * intensity),
      ];

  static List<BoxShadow> redGlow([double intensity = 1.0]) => [
        BoxShadow(color: neonRed.withValues(alpha: 0.4 * intensity), blurRadius: 24 * intensity, spreadRadius: 2 * intensity),
      ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  // ── Dark ThemeData ────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: darkSurface,
        error: neonRed,
        onPrimary: darkBg,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.exo2TextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: textPrimary, letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: 1,
        ),
        titleMedium: GoogleFonts.exo2(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.exo2(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.exo2(
          fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        bodySmall: GoogleFonts.exo2(
          fontSize: 12, fontWeight: FontWeight.w400, color: textMuted,
        ),
        labelLarge: GoogleFonts.exo2(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: neonCyan),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: textPrimary, letterSpacing: 1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: darkBg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.exo2(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neonCyan, width: 1.5)),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.exo2(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? neonCyan : textMuted),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? neonCyan.withValues(alpha: 0.3)
                : darkBorder),
      ),
    );
  }

  // ── Light ThemeData ───────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      colorScheme: ColorScheme.light(
        primary: neonBlue,
        secondary: neonPurple,
        surface: Colors.white,
        error: neonRed,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1E293B),
      ),
      textTheme: GoogleFonts.exo2TextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B), letterSpacing: 1,
        ),
      ),
    );
  }

  // ── Helper: Orbitron text style ───────────────────────────
  static TextStyle orbitron({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = textPrimary,
    double letterSpacing = 1,
  }) =>
      GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
