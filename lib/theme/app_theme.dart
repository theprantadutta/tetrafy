import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  // 🌌 Aurora Theme - Northern Lights
  static final ThemeData auroraTheme = ThemeData.from(
    colorScheme: aurora,
    useMaterial3: true,
  );

  // 🌆 Synthwave Theme - 80s Futuristic
  static final ThemeData synthwaveTheme = ThemeData.from(
    colorScheme: synthwave,
    useMaterial3: true,
  );

  // 🌠 Cosmic Theme - Deep Space
  static final ThemeData cosmicTheme = ThemeData.from(
    colorScheme: cosmic,
    useMaterial3: true,
  );

  // 🏮 Neon Tokyo Theme - Japanese Cyberpunk
  static final ThemeData neonTokyoTheme = ThemeData.from(
    colorScheme: neonTokyo,
    useMaterial3: true,
  );

  // 🌊 Ocean Deep Theme - Bioluminescence
  static final ThemeData oceanDeepTheme = ThemeData.from(
    colorScheme: oceanDeep,
    useMaterial3: true,
  );

  // 🕹️ Sunset Arcade Theme - Retro Modern
  static final ThemeData sunsetArcadeTheme = ThemeData.from(
    colorScheme: sunsetArcade,
    useMaterial3: true,
  );

  // Helper method to get theme by name
  static ThemeData getThemeByName(String name) {
    switch (name) {
      case 'aurora':
        return auroraTheme;
      case 'synthwave':
        return synthwaveTheme;
      case 'cosmic':
        return cosmicTheme;
      case 'neonTokyo':
        return neonTokyoTheme;
      case 'oceanDeep':
        return oceanDeepTheme;
      case 'sunsetArcade':
        return sunsetArcadeTheme;
      default:
        return auroraTheme; // Default theme
    }
  }

  // Get all available theme names
  static List<String> get themeNames => [
        'aurora',
        'synthwave',
        'cosmic',
        'neonTokyo',
        'oceanDeep',
        'sunsetArcade',
      ];

  // Get theme display names
  static Map<String, String> get themeDisplayNames => {
        'aurora': 'Aurora',
        'synthwave': 'Synthwave',
        'cosmic': 'Cosmic',
        'neonTokyo': 'Neon Tokyo',
        'oceanDeep': 'Ocean Deep',
        'sunsetArcade': 'Sunset Arcade',
      };
}