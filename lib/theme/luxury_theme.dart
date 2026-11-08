import 'package:flutter/material.dart';

/// Luxury Theme with STRICT NO-BLUE, NO-RED, NO-MAGENTA compliance.
/// Supports dynamic Dark (Obsidian Carbon) and Light (Platinum Alabaster) modes.
class LuxuryTheme {
  static final ValueNotifier<bool> isDarkNotifier = ValueNotifier<bool>(true);
  static bool get isDark => isDarkNotifier.value;

  static void toggleTheme() {
    isDarkNotifier.value = !isDarkNotifier.value;
  }

  // Dark Palette (Obsidian Carbon & Cyber Emerald)
  static const Color _darkBackground = Color(0xFF090D0B);
  static const Color _darkSurfaceDark = Color(0xFF101613);
  static const Color _darkSurfaceCard = Color(0xFF161F1A);
  static const Color _darkSurfaceCardElevated = Color(0xFF1D2822);
  static const Color _darkBorderMuted = Color(0xFF26352D);
  static const Color _darkBorderGlowing = Color(0xFF32493D);

  static const Color _darkEmeraldPrimary = Color(0xFF00E599);
  static const Color _darkEmeraldBright = Color(0xFF34F5B0);
  static const Color _darkEmeraldMuted = Color(0xFF059669);
  static const Color _darkEmeraldDark = Color(0xFF064E3B);

  static const Color _darkGoldPrimary = Color(0xFFFBBF24);
  static const Color _darkGoldWarm = Color(0xFFF59E0B);
  static const Color _darkGoldDark = Color(0xFFB45309);

  static const Color _darkOchreWarm = Color(0xFFF97316);
  static const Color _darkOchreMuted = Color(0xFFEA580C);

  static const Color _darkTextBright = Color(0xFFF9FAFB);
  static const Color _darkTextMuted = Color(0xFF9CA3AF);
  static const Color _darkTextSubtle = Color(0xFF6B7280);

  static const Color _darkKeyNumberBg = Color(0xFF141C18);
  static const Color _darkKeyOpBg = Color(0xFF1C241F);
  static const Color _darkKeyFnBg = Color(0xFF122018);

  // Light Palette (Platinum Alabaster & Forest Jade - STRICTLY NO BLUE, NO RED, NO MAGENTA)
  static const Color _lightBackground = Color(0xFFF4F6F4);
  static const Color _lightSurfaceDark = Color(0xFFEAEEEA);
  static const Color _lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color _lightSurfaceCardElevated = Color(0xFFF7F9F7);
  static const Color _lightBorderMuted = Color(0xFFD2DBD4);
  static const Color _lightBorderGlowing = Color(0xFFA5B8AB);

  static const Color _lightEmeraldPrimary = Color(0xFF047857);
  static const Color _lightEmeraldBright = Color(0xFF059669);
  static const Color _lightEmeraldMuted = Color(0xFF10B981);
  static const Color _lightEmeraldDark = Color(0xFFD1FAE5);

  static const Color _lightGoldPrimary = Color(0xFFB45309);
  static const Color _lightGoldWarm = Color(0xFFD97706);
  static const Color _lightGoldDark = Color(0xFFFEF3C7);

  static const Color _lightOchreWarm = Color(0xFFC2410C); // Burnt terracotta, NO RED
  static const Color _lightOchreMuted = Color(0xFFEA580C);

  static const Color _lightTextBright = Color(0xFF0E1712); // Deep carbon slate
  static const Color _lightTextMuted = Color(0xFF4B554E);
  static const Color _lightTextSubtle = Color(0xFF78857C);

  static const Color _lightKeyNumberBg = Color(0xFFFFFFFF);
  static const Color _lightKeyOpBg = Color(0xFFFEF3C7);
  static const Color _lightKeyFnBg = Color(0xFFE8F7F0);

  // Dynamic Getters
  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get surfaceDark => isDark ? _darkSurfaceDark : _lightSurfaceDark;
  static Color get surfaceCard => isDark ? _darkSurfaceCard : _lightSurfaceCard;
  static Color get surfaceCardElevated => isDark ? _darkSurfaceCardElevated : _lightSurfaceCardElevated;
  static Color get borderMuted => isDark ? _darkBorderMuted : _lightBorderMuted;
  static Color get borderGlowing => isDark ? _darkBorderGlowing : _lightBorderGlowing;

  static Color get emeraldPrimary => isDark ? _darkEmeraldPrimary : _lightEmeraldPrimary;
  static Color get emeraldBright => isDark ? _darkEmeraldBright : _lightEmeraldBright;
  static Color get emeraldMuted => isDark ? _darkEmeraldMuted : _lightEmeraldMuted;
  static Color get emeraldDark => isDark ? _darkEmeraldDark : _lightEmeraldDark;
  static Color get emeraldGlow => isDark ? const Color(0x6600E599) : const Color(0x40047857);
  static Color get emeraldSubtle => isDark ? const Color(0x1A00E599) : const Color(0x1A047857);

  static Color get goldPrimary => isDark ? _darkGoldPrimary : _lightGoldPrimary;
  static Color get goldWarm => isDark ? _darkGoldWarm : _lightGoldWarm;
  static Color get goldDark => isDark ? _darkGoldDark : _lightGoldDark;
  static Color get goldGlow => isDark ? const Color(0x66FBBF24) : const Color(0x40B45309);
  static Color get goldSubtle => isDark ? const Color(0x1AFBBF24) : const Color(0x1AB45309);

  static Color get ochreWarm => isDark ? _darkOchreWarm : _lightOchreWarm;
  static Color get ochreMuted => isDark ? _darkOchreMuted : _lightOchreMuted;
  static Color get ochreGlow => isDark ? const Color(0x55F97316) : const Color(0x35C2410C);
  static Color get ochreSubtle => isDark ? const Color(0x1DF97316) : const Color(0x1DC2410C);

  static Color get textBright => isDark ? _darkTextBright : _lightTextBright;
  static Color get textMuted => isDark ? _darkTextMuted : _lightTextMuted;
  static Color get textSubtle => isDark ? _darkTextSubtle : _lightTextSubtle;

  static Color get keyNumberBg => isDark ? _darkKeyNumberBg : _lightKeyNumberBg;
  static Color get keyOpBg => isDark ? _darkKeyOpBg : _lightKeyOpBg;
  static Color get keyFnBg => isDark ? _darkKeyFnBg : _lightKeyFnBg;

  static ThemeData get themeData {
    final dark = isDark;
    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: emeraldPrimary,
      canvasColor: background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: emeraldPrimary,
        onPrimary: dark ? const Color(0xFF042014) : Colors.white,
        secondary: goldPrimary,
        onSecondary: dark ? const Color(0xFF201602) : Colors.white,
        surface: surfaceCard,
        onSurface: textBright,
        error: ochreWarm, // Orange-ochre for error, NEVER red
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderMuted, width: 1),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceCardElevated,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(BorderSide(color: emeraldMuted)),
        ),
        textStyle: TextStyle(color: textBright, fontSize: 12),
      ),
    );
  }
}
