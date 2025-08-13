import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../utils/tetromino_data.dart';

class PiecePreview extends StatelessWidget {
  final Piece? piece;

  const PiecePreview({super.key, this.piece});

  @override
  Widget build(BuildContext context) {
    if (piece == null) {
      return const Center(
        child: Text(
          'Empty',
          style: TextStyle(fontSize: 8),
        ),
      );
    }

    // Get the points for the piece at rotation 0 (default preview)
    final points = tetrominoData[piece!.type]![0];
    
    // Find the bounds of the piece to center it
    int minX = points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    int maxX = points.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    int minY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    int maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    
    // Calculate grid size
    final gridWidth = maxX - minX + 1;
    final gridHeight = maxY - minY + 1;
    
    // Calculate offset to center the piece
    final offsetX = (4 - gridWidth) ~/ 2 - minX;
    final offsetY = (4 - gridHeight) ~/ 2 - minY;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        final x = index % 4;
        final y = index ~/ 4;
        
        // Check if this cell should contain part of the piece
        final isPiece = points.any((point) => 
          point.x + offsetX == x && point.y + offsetY == y);
        
        return Container(
          margin: const EdgeInsets.all(1),
          color: isPiece ? piece!.color : Colors.transparent,
        );
      },
    );
  }
}