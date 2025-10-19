import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/preferences_service.dart';
import '../services/player_profile_service.dart';
import '../widgets/particle_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/glow_progress_bar.dart';
import '../widgets/glass_button.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesService>(context);
    final profileService = PlayerProfileService();

    return ValueListenableBuilder<String>(
      valueListenable: currentThemeNameNotifier,
      builder: (context, themeName, child) {
        return FutureBuilder(
          future: profileService.getProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                body: Stack(
                  children: [
                    const ParticleBackground(),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            }

            final profile = snapshot.data!;
            final totalTimePlayed = preferences.totalTimePlayed;
            final totalLinesCleared = preferences.totalLinesCleared;
            final averageSpeed = totalTimePlayed > 0
                ? (totalLinesCleared / (totalTimePlayed / 60))
                : 0.0;
            final theme = Theme.of(context);

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
                                text: 'STATS',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Player Profile Card
                                GlassCard(
                                  showGlow: true,
                                  child: Column(
                                    children: [
                                      // Profile Icon
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                              blurRadius: 20,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Player Level
                                      Text(
                                        'LEVEL ${profile.level}',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        '${profile.xp} / ${profile.level * 100} XP',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // XP Progress Bar
                                      AnimatedGlowProgressBar(
                                        value: profile.xp / (profile.level * 100),
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // High Scores Grid
                                GlassCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            color: theme.colorScheme.secondary,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'HIGH SCORES',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: theme.colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1.5,
                                        children: [
                                          _buildStatCard(
                                            context,
                                            'Classic',
                                            preferences.highScoreClassic,
                                            Icons.stars,
                                          ),
                                          _buildStatCard(
                                            context,
                                            'Sprint',
                                            preferences.highScoreSprint,
                                            Icons.speed,
                                          ),
                                          _buildStatCard(
                                            context,
                                            'Marathon',
                                            preferences.highScoreMarathon,
                                            Icons.all_inclusive,
                                          ),
                                          _buildStatCard(
                                            context,
                                            'Zen',
                                            preferences.highScoreZen,
                                            Icons.spa,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Overall Stats
                                GlassCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.bar_chart,
                                            color: theme.colorScheme.tertiary,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'OVERALL STATS',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: theme.colorScheme.tertiary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      _buildStatRow(
                                        context,
                                        'Total Lines Cleared',
                                        totalLinesCleared.toString(),
                                        Icons.layers_clear,
                                      ),
                                      const SizedBox(height: 16),

                                      _buildStatRow(
                                        context,
                                        'Total Blocks Dropped',
                                        preferences.totalBlocksDropped.toString(),
                                        Icons.arrow_downward,
                                      ),
                                      const SizedBox(height: 16),

                                      _buildStatRow(
                                        context,
                                        'Time Played',
                                        '${(totalTimePlayed / 60).toStringAsFixed(1)} min',
                                        Icons.access_time,
                                      ),
                                      const SizedBox(height: 16),

                                      _buildStatRow(
                                        context,
                                        'Average Speed',
                                        '${averageSpeed.toStringAsFixed(1)} lines/min',
                                        Icons.speed,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Back Button
                                GlassButton(
                                  text: 'BACK',
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icons.arrow_back,
                                  width: double.infinity,
                                ),

                                const SizedBox(height: 20),
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
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, int value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.tertiary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
