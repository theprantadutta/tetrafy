import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/particle_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_text.dart';

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'CLASSIC':
        return Icons.stars;
      case 'SPRINT':
        return Icons.speed;
      case 'MARATHON':
        return Icons.all_inclusive;
      case 'ZEN':
        return Icons.spa;
      default:
        return Icons.videogame_asset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<String>(
      valueListenable: currentThemeNameNotifier,
      builder: (context, themeName, child) {
        return Scaffold(
          body: Stack(
            children: [
              const ParticleBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          GradientText(
                            text: 'GAME MODES',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModeCard(
                              context,
                              title: 'CLASSIC',
                              description:
                                  'The traditional Tetris experience. Clear lines to level up and try to reach level 15 to win the game. The game speeds up as you level up, making it increasingly challenging.',
                              features: [
                                'Level up by clearing lines',
                                'Game ends at level 15',
                                'Speed increases with each level',
                                'Standard scoring system',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildModeCard(
                              context,
                              title: 'SPRINT',
                              description:
                                  'Race against the clock to clear 40 lines as fast as possible. This mode is all about speed and efficiency.',
                              features: [
                                'Clear 40 lines to complete',
                                'No level progression',
                                'Focus on speed and technique',
                                'Compete for the fastest time',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildModeCard(
                              context,
                              title: 'MARATHON',
                              description:
                                  'Endless gameplay where you can keep playing and leveling up indefinitely. See how far you can go!',
                              features: [
                                'No level cap - play forever',
                                'Continuous level progression',
                                'Increasing difficulty',
                                'Test your endurance',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildModeCard(
                              context,
                              title: 'ZEN',
                              description:
                                  'A relaxing mode without time pressure. Pieces only move when you control them, perfect for a calm gaming experience.',
                              features: [
                                'No automatic piece movement',
                                'No scoring or levels',
                                'Relaxing gameplay',
                                'Control the pace yourself',
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> features,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      showGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getModeIcon(title),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Features:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
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