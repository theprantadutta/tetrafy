import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/block_skin.dart';
import 'models/game_mode.dart';
import 'models/game_model.dart';
import 'models/player_profile.dart';
import 'screens/game_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/stats_screen.dart';
import 'services/player_profile_service.dart';
import 'services/preferences_service.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';
import 'widgets/game_board.dart';
import 'widgets/piece_preview.dart';

final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(
  AppTheme.lightTheme,
);
final ValueNotifier<BlockSkin> blockSkinNotifier = ValueNotifier(
  BlockSkin.flat,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final theme = preferences.getString('theme') ?? 'pastel';
  final skin = preferences.getString('skin') ?? 'flat';
  themeNotifier.value = _getThemeData(theme);
  blockSkinNotifier.value = _getBlockSkin(skin);
  runApp(
    ChangeNotifierProvider(
      create: (context) => PreferencesService(),
      child: const MyApp(),
    ),
  );
}

ThemeData _getThemeData(String theme) {
  switch (theme) {
    case 'pastel':
      return AppTheme.lightTheme;
    case 'retroNeon':
      return AppTheme.darkTheme;
    case 'monochrome':
      return AppTheme.monochromeTheme;
    case 'cyberpunk':
      return AppTheme.cyberpunkTheme;
    default:
      return AppTheme.lightTheme;
  }
}

BlockSkin _getBlockSkin(String skin) {
  switch (skin) {
    case 'flat':
      return BlockSkin.flat;
    case 'glossy':
      return BlockSkin.glossy;
    case 'pixelArt':
      return BlockSkin.pixelArt;
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
        return MaterialApp(
          title: 'Tetras',
          theme: theme.copyWith(
            textTheme: GoogleFonts.pressStart2pTextTheme(
              theme.textTheme,
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          home: const ModeSelectionScreen(),
          routes: {
            '/stats': (context) => const StatsScreen(),
            '/game': (context) => const GameScreen(),
          },
        );
      },
    );
  }
}
