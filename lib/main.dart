
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/block_skin.dart';
import 'screens/game_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/stats_screen.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';

final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(
  AppTheme.auroraTheme,
);
final ValueNotifier<String> currentThemeNameNotifier = ValueNotifier('aurora');
final ValueNotifier<BlockSkin> blockSkinNotifier = ValueNotifier(
  BlockSkin.flat,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final theme = preferences.getString('theme') ?? 'aurora';
  final skin = preferences.getString('skin') ?? 'flat';
  themeNotifier.value = AppTheme.getThemeByName(theme);
  currentThemeNameNotifier.value = theme;
  blockSkinNotifier.value = _getBlockSkin(skin);
  runApp(
    ChangeNotifierProvider(
      create: (context) => PreferencesService(),
      child: const MyApp(),
    ),
  );
}

BlockSkin _getBlockSkin(String skin) {
  switch (skin) {
    case 'flat':
      return BlockSkin.flat;
    case 'glossy':
      return BlockSkin.glossy;
    case 'pixelArt':
      return BlockSkin.pixelArt;
    case 'neon':
      return BlockSkin.neon;
    case 'holographic':
      return BlockSkin.holographic;
    case 'crystal':
      return BlockSkin.crystal;
    case 'gem':
      return BlockSkin.gem;
    case 'glass':
      return BlockSkin.glass;
    default:
      return BlockSkin.flat;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, theme, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MaterialApp(
            title: 'Tetrafy',
            theme: theme.copyWith(
              textTheme: GoogleFonts.orbitronTextTheme(
                theme.textTheme,
              ).copyWith(
                // Display styles (large titles)
                displayLarge: GoogleFonts.orbitron(
                  fontSize: 57,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.25,
                  color: theme.colorScheme.onSurface,
                ),
                displayMedium: GoogleFonts.orbitron(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                displaySmall: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                // Headline styles
                headlineLarge: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                headlineMedium: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                headlineSmall: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                // Title styles
                titleLarge: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                titleMedium: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                  color: theme.colorScheme.onSurface,
                ),
                titleSmall: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: theme.colorScheme.onSurface,
                ),
                // Body styles
                bodyLarge: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                ),
                bodyMedium: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.25,
                  color: theme.colorScheme.onSurface,
                ),
                bodySmall: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.4,
                  color: theme.colorScheme.onSurface,
                ),
                // Label styles (for buttons, etc.)
                labelLarge: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                  color: theme.colorScheme.onSurface,
                ),
                labelMedium: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                ),
                labelSmall: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              scaffoldBackgroundColor: theme.colorScheme.surface,
            ),
            home: const ModeSelectionScreen(),
            routes: {
              '/stats': (context) => const StatsScreen(),
              '/game': (context) => const GameScreen(),
            },
          ),
        );
      },
    );
  }
}
