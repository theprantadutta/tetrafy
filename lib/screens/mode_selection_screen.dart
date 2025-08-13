import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_mode.dart';
import '../widgets/particle_background.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title with a glowing effect
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.cyan, Colors.pink, Colors.purple],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds),
                    child: Text(
                      'TETRAFY',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 48,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.cyan.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                          Shadow(
                            color: Colors.pink.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Subtitle
                  Text(
                    'The Ultimate Block Puzzle',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Game mode selection buttons
                  ...GameMode.values.map(
                    (mode) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: 240,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(gameMode: mode),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              width: 3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 10,
                            shadowColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.all(15),
                          ),
                          child: Text(
                            mode.toString().split('.').last.toUpperCase(),
                            style: GoogleFonts.pressStart2p(
                              fontSize: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Stats button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 240,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatsScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            width: 3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          'STATS',
                          style: GoogleFonts.pressStart2p(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}