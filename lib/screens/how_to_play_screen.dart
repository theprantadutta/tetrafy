import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/particle_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_text.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

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
                            text: 'HOW TO PLAY',
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
                            _buildSection(
                              context,
                              icon: Icons.gamepad,
                              title: 'BASIC CONTROLS',
                              content:
                                  'Use the arrow keys or on-screen controls to move and rotate the falling blocks (tetrominoes):',
                              items: [
                                '← → : Move piece left/right',
                                '↑ : Rotate piece',
                                '↓ : Move piece down faster',
                                'SPACE : Hard drop (instantly drop piece)',
                                'C : Hold current piece',
                                'P : Pause game',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              icon: Icons.track_changes,
                              title: 'GAME OBJECTIVE',
                              content:
                                  'Arrange the falling tetrominoes to form complete horizontal lines. When a line is completed, it disappears and you earn points.',
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              icon: Icons.emoji_events,
                              title: 'SCORING SYSTEM',
                              content:
                                  'Points are awarded based on the number of lines cleared at once and your current level:',
                              items: [
                                '1 line (Single): 100 × level points',
                                '2 lines (Double): 300 × level points',
                                '3 lines (Triple): 500 × level points',
                                '4 lines (Tetris): 800 × level points',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              icon: Icons.layers_clear,
                              title: 'LINE CLEARING',
                              content:
                                  'When you complete a horizontal line with blocks, that line disappears and all blocks above it move down. Clearing multiple lines at once gives higher scores.',
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              icon: Icons.inventory_2,
                              title: 'HOLD PIECE',
                              content:
                                  'You can hold one piece at a time by pressing the C key. This allows you to save a piece for later and swap it with your current piece.',
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              context,
                              icon: Icons.dangerous,
                              title: 'GAME OVER',
                              content:
                                  'The game ends when a new piece cannot enter the playfield because it is blocked by existing pieces. This happens when the stack of blocks reaches the top of the playfield.',
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    List<String>? items,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          if (items != null) ...[
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
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
                        item,
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
        ],
      ),
    );
  }
}