import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/particle_background.dart';

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const ParticleBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'GAME MODES',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 24,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {
    required String title,
    required String description,
    required List<String> features,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.pressStart2p(
                fontSize: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}