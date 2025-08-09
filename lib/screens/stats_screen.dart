import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrafy/services/preferences_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    final textTheme = Theme.of(context).textTheme;
    final totalTimePlayed = prefs.totalTimePlayed;
    final totalLinesCleared = prefs.totalLinesCleared;
    final averageSpeed =
        totalTimePlayed > 0 ? (totalLinesCleared / (totalTimePlayed / 60)) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            title: 'Best Score (Classic)',
            value: prefs.highScoreClassic.toString(),
            icon: Icons.emoji_events,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Best Score (Sprint)',
            value: prefs.highScoreSprint.toString(),
            icon: Icons.emoji_events,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Best Score (Marathon)',
            value: prefs.highScoreMarathon.toString(),
            icon: Icons.emoji_events,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Best Score (Zen)',
            value: prefs.highScoreZen.toString(),
            icon: Icons.emoji_events,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Total Lines Cleared',
            value: prefs.totalLinesCleared.toString(),
            icon: Icons.clear_all,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Average Speed (lines/min)',
            value: averageSpeed.toStringAsFixed(2),
            icon: Icons.speed,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Total Blocks Dropped',
            value: prefs.totalBlocksDropped.toString(),
            icon: Icons.view_in_ar,
            context: context,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Menu'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement screenshot and sharing functionality
            },
            child: const Text('Share Score'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}