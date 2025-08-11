import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_mode.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TETRAFY',
              style: GoogleFonts.pressStart2p(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            ...GameMode.values.map(
              (mode) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(gameMode: mode),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      side: const BorderSide(color: Colors.white),
                      shape: const BeveledRectangleBorder(),
                    ),
                    child: Text(
                      mode.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}