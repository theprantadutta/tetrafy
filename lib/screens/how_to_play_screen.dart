import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/particle_background.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

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
                    'HOW TO PLAY',
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
                          _buildSection(
                            context,
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
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
                            title: 'GAME OBJECTIVE',
                            content:
                                'Arrange the falling tetrominoes to form complete horizontal lines. When a line is completed, it disappears and you earn points.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
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
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
                            title: 'LINE CLEARING',
                            content:
                                'When you complete a horizontal line with blocks, that line disappears and all blocks above it move down. Clearing multiple lines at once gives higher scores.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
                            title: 'HOLD PIECE',
                            content:
                                'You can hold one piece at a time by pressing the C key. This allows you to save a piece for later and swap it with your current piece.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            context,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required String content,
    List<String>? items,
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
              content,
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
            if (items != null) ...[
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
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
                          item,
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
          ],
        ),
      ),
    );
  }
}