import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tetrafy/services/preferences_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesService>(context);
    final totalTimePlayed = preferences.totalTimePlayed;
    final totalLinesCleared = preferences.totalLinesCleared;
    final averageSpeed = totalTimePlayed > 0
        ? (totalLinesCleared / (totalTimePlayed / 60))
        : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                'STATS',
                style: GoogleFonts.pressStart2p(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildStatTile(
              title: 'High Score',
              value: preferences.highScoreClassic.toString(),
            ),
            _buildStatTile(
              title: 'Total Lines Cleared',
              value: preferences.totalLinesCleared.toString(),
            ),
            _buildStatTile(
              title: 'Total Time Played',
              value: '${(totalTimePlayed / 60).toStringAsFixed(2)} minutes',
            ),
            _buildStatTile(
              title: 'Average Speed',
              value: '${averageSpeed.toStringAsFixed(2)} lines/min',
            ),
            _buildStatTile(
              title: 'Total Blocks Dropped',
              value: preferences.totalBlocksDropped.toString(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: const BeveledRectangleBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'BACK',
                    style: GoogleFonts.pressStart2p(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({required String title, required String value}) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
