import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../services/preferences_service.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Pastel'),
            onTap: () {
              themeNotifier.value = AppTheme.lightTheme;
              PreferencesService().setTheme('pastel');
            },
          ),
          ListTile(
            title: const Text('Retro Neon'),
            onTap: () {
              themeNotifier.value = AppTheme.darkTheme;
              PreferencesService().setTheme('retroNeon');
            },
          ),
          ListTile(
            title: const Text('Monochrome'),
            onTap: () {
              themeNotifier.value = AppTheme.monochromeTheme;
              PreferencesService().setTheme('monochrome');
            },
          ),
          ListTile(
            title: const Text('Cyberpunk'),
            onTap: () {
              themeNotifier.value = AppTheme.cyberpunkTheme;
              PreferencesService().setTheme('cyberpunk');
            },
          ),
        ],
      ),
    );
  }
}