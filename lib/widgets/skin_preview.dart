import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/block_skin.dart';

class SkinPreview extends StatelessWidget {
  final BlockSkin skin;
  final bool isSelected;

  const SkinPreview({
    super.key,
    required this.skin,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for skin preview
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getSkinPreviewColor(skin),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            skin.toString().split('.').last,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkinPreviewColor(BlockSkin skin) {
    switch (skin) {
      case BlockSkin.flat:
        return Colors.blue;
      case BlockSkin.glossy:
        return Colors.red;
      case BlockSkin.pixelArt:
        return Colors.green;
    }
  }
}