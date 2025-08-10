import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../main.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Mode'),
      ),
      body: ListView(
        children: [
          ...GameMode.values
              .map(
                (mode) => ListTile(
                  title: Text(mode.toString().split('.').last),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(gameMode: mode),
                      ),
                    );
                  },
                ),
              )
              ,
          ListTile(
            title: const Text('Stats'),
            onTap: () {
              Navigator.pushNamed(context, '/stats');
            },
          ),
        ],
      ),
    );
  }
}