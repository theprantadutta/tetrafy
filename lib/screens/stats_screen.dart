import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tetrafy/services/preferences_service.dart';
import 'package:tetrafy/services/player_profile_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesService>(context);
    final profileService = PlayerProfileService();
    
    return FutureBuilder(
      future: profileService.getProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final profile = snapshot.data!;
        final totalTimePlayed = preferences.totalTimePlayed;
        final totalLinesCleared = preferences.totalLinesCleared;
        final averageSpeed = totalTimePlayed > 0
            ? (totalLinesCleared / (totalTimePlayed / 60))
            : 0;
        final theme = Theme.of(context);

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'PLAYER STATS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 32,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Player Level
                _buildStatTile(
                  title: 'Player Level',
                  value: profile.level.toString(),
                  subtitle: '${profile.xp}/${profile.level * 100} XP',
                  theme: theme,
                ),
                const SizedBox(height: 10),
                // Progress bar for level
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: profile.xp / (profile.level * 100),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatTile(
                  title: 'High Score',
                  value: preferences.highScoreClassic.toString(),
                  theme: theme,
                ),
                _buildStatTile(
                  title: 'Total Lines Cleared',
                  value: preferences.totalLinesCleared.toString(),
                  theme: theme,
                ),
                _buildStatTile(
                  title: 'Total Time Played',
                  value: '${(totalTimePlayed / 60).toStringAsFixed(2)} minutes',
                  theme: theme,
                ),
                _buildStatTile(
                  title: 'Average Speed',
                  value: '${averageSpeed.toStringAsFixed(2)} lines/min',
                  theme: theme,
                ),
                _buildStatTile(
                  title: 'Total Blocks Dropped',
                  value: preferences.totalBlocksDropped.toString(),
                  theme: theme,
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(color: theme.colorScheme.onSurface, width: 2),
                      shape: const BeveledRectangleBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'BACK',
                        style: GoogleFonts.pressStart2p(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatTile({required String title, required String value, String? subtitle, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: GoogleFonts.pressStart2p(color: theme.colorScheme.onSurface, fontSize: 14),
          ),
          trailing: Text(
            value,
            style: GoogleFonts.pressStart2p(color: theme.colorScheme.primary, fontSize: 14),
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              subtitle,
              style: GoogleFonts.pressStart2p(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 10),
            ),
          ),
      ],
    );
  }
}
