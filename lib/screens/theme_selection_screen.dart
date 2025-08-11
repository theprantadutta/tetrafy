import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/preferences_service.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              'THEME SELECTION',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<PreferencesService>(
                builder: (context, preferences, child) {
                  final currentTheme = preferences.currentTheme;
                  return ListView(
                    children: [
                      _buildThemeTile(
                        context: context,
                        title: 'Pastel',
                        theme: AppTheme.lightTheme,
                        themeName: 'pastel',
                        currentTheme: currentTheme,
                      ),
                      _buildThemeTile(
                        context: context,
                        title: 'Retro Neon',
                        theme: AppTheme.darkTheme,
                        themeName: 'retroNeon',
                        currentTheme: currentTheme,
                      ),
                      _buildThemeTile(
                        context: context,
                        title: 'Monochrome',
                        theme: AppTheme.monochromeTheme,
                        themeName: 'monochrome',
                        currentTheme: currentTheme,
                      ),
                      _buildThemeTile(
                        context: context,
                        title: 'Cyberpunk',
                        theme: AppTheme.cyberpunkTheme,
                        themeName: 'cyberpunk',
                        currentTheme: currentTheme,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required ThemeData theme,
    required String themeName,
    required String currentTheme,
  }) {
    final isSelected = currentTheme == themeName;
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.pressStart2p(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.white)
          : null,
      onTap: () {
        themeNotifier.value = theme;
        Provider.of<PreferencesService>(context, listen: false)
            .setTheme(themeName);
      },
    );
  }
}