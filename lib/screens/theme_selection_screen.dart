import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/preferences_service.dart';
import '../widgets/particle_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_text.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  String _getThemeDescription(String themeName) {
    switch (themeName) {
      case 'aurora':
        return 'Northern Lights inspired with flowing colors';
      case 'synthwave':
        return '80s futuristic grid and neon vibes';
      case 'cosmic':
        return 'Deep space with twinkling stars';
      case 'neonTokyo':
        return 'Japanese cyberpunk with rain effects';
      case 'oceanDeep':
        return 'Underwater bioluminescence';
      case 'sunsetArcade':
        return 'Retro arcade sunset gradients';
      default:
        return '';
    }
  }

  IconData _getThemeIcon(String themeName) {
    switch (themeName) {
      case 'aurora':
        return Icons.wb_twilight;
      case 'synthwave':
        return Icons.grid_on;
      case 'cosmic':
        return Icons.nights_stay;
      case 'neonTokyo':
        return Icons.location_city;
      case 'oceanDeep':
        return Icons.waves;
      case 'sunsetArcade':
        return Icons.videogame_asset;
      default:
        return Icons.palette;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: currentThemeNameNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Particle background
              const ParticleBackground(),

              // Content
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
                            text: 'THEMES',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),

                    // Theme grid
                    Expanded(
                      child: Consumer<PreferencesService>(
                        builder: (context, preferences, child) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: AppTheme.themeNames.length,
                            itemBuilder: (context, index) {
                              final themeName = AppTheme.themeNames[index];
                              final displayName = AppTheme.themeDisplayNames[themeName]!;
                              final isSelected = currentTheme == themeName;

                              return _buildThemeCard(
                                context,
                                themeName,
                                displayName,
                                isSelected,
                              );
                            },
                          );
                        },
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

  Widget _buildThemeCard(
    BuildContext context,
    String themeName,
    String displayName,
    bool isSelected,
  ) {
    final themeData = AppTheme.getThemeByName(themeName);

    return GlassCard(
      showGlow: isSelected,
      borderColor: isSelected
          ? themeData.colorScheme.primary
          : themeData.colorScheme.primary.withValues(alpha: 0.2),
      borderWidth: isSelected ? 2.5 : 1,
      onTap: () {
        themeNotifier.value = themeData;
        currentThemeNameNotifier.value = themeName;
        Provider.of<PreferencesService>(context, listen: false)
            .setTheme(themeName);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Theme preview icon with colors
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.secondary,
                    themeData.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: themeData.colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: themeData.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _getThemeIcon(themeName),
                color: Colors.white,
                size: 35,
              ),
            ),

            const SizedBox(width: 20),

            // Theme info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: themeData.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: themeData.colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getThemeDescription(themeName),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: themeData.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Color dots preview
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorDot(themeData.colorScheme.primary),
                const SizedBox(height: 6),
                _buildColorDot(themeData.colorScheme.secondary),
                const SizedBox(height: 6),
                _buildColorDot(themeData.colorScheme.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}