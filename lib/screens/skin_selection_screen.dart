import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/block_skin.dart';
import '../main.dart';
import '../services/preferences_service.dart';
import '../widgets/skin_preview.dart';

class SkinSelectionScreen extends StatelessWidget {
  const SkinSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'SKIN SELECTION',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<BlockSkin>(
                valueListenable: blockSkinNotifier,
                builder: (context, currentSkin, child) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: BlockSkin.values.length,
                    itemBuilder: (context, index) {
                      final skin = BlockSkin.values[index];
                      return GestureDetector(
                        onTap: () {
                          blockSkinNotifier.value = skin;
                          PreferencesService()
                              .setSkin(skin.toString().split('.').last);
                        },
                        child: SkinPreview(
                          skin: skin,
                          isSelected: currentSkin == skin,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}