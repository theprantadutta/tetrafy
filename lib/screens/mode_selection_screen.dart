import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../widgets/particle_background.dart';
import '../widgets/gradient_text.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_card.dart';
import 'game_modes_screen.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'stats_screen.dart';
import 'theme_selection_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return Icons.stars;
      case GameMode.sprint:
        return Icons.speed;
      case GameMode.marathon:
        return Icons.all_inclusive;
      case GameMode.zen:
        return Icons.spa;
    }
  }

  String _getModeDescription(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Classic Tetris Experience';
      case GameMode.sprint:
        return 'Race Against Time';
      case GameMode.marathon:
        return 'Endless Gameplay';
      case GameMode.zen:
        return 'Relaxing Mode';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Particle background
          const ParticleBackground(),

          // Main content - doesn't rebuild on theme changes
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  // Title with animated gradient
                  AnimatedGradientText(
                    text: 'TETRAFY',
                    style: theme.textTheme.displayLarge,
                    showGlow: true,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'The Ultimate Block Puzzle',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Game Mode Cards in Grid - Takes available space
                  Expanded(
                    flex: 6,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: GameMode.values.length,
                      itemBuilder: (context, index) {
                        final mode = GameMode.values[index];
                        return _buildModeCard(context, mode);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom buttons row - Fixed size
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: (size.width - 50) / 2,
                        child: GlassButton(
                          text: 'HOW TO PLAY',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HowToPlayScreen(),
                              ),
                            );
                          },
                          icon: Icons.help_outline,
                          isOutlined: true,
                          isPrimary: false,
                          height: 48,
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 50) / 2,
                        child: GlassButton(
                          text: 'GAME MODES',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameModesScreen(),
                              ),
                            );
                          },
                          icon: Icons.info_outline,
                          isOutlined: true,
                          isPrimary: false,
                          height: 48,
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 50) / 2,
                        child: GlassButton(
                          text: 'STATS',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StatsScreen(),
                              ),
                            );
                          },
                          icon: Icons.bar_chart,
                          isOutlined: true,
                          isPrimary: false,
                          height: 48,
                        ),
                      ),
                      SizedBox(
                        width: (size.width - 50) / 2,
                        child: GlassButton(
                          text: 'THEMES',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ThemeSelectionScreen(),
                              ),
                            );
                          },
                          icon: Icons.palette_outlined,
                          isOutlined: true,
                          isPrimary: false,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, GameMode mode) {
    final theme = Theme.of(context);
    final modeName = mode.toString().split('.').last.toUpperCase();

    return GlassCard(
      showGlow: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(gameMode: mode),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight;
          final iconSize = (cardHeight * 0.25).clamp(50.0, 70.0);

          return Padding(
            padding: EdgeInsets.all(cardHeight * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with glow - Flexible size
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.secondary.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(iconSize * 0.25),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getModeIcon(mode),
                    color: theme.colorScheme.primary,
                    size: iconSize * 0.5,
                  ),
                ),

                SizedBox(height: cardHeight * 0.05),

                // Mode name - Flexible
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      modeName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),

                SizedBox(height: cardHeight * 0.02),

                // Description - Flexible
                Flexible(
                  child: Text(
                    _getModeDescription(mode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}