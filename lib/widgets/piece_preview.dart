import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/point.dart';
import '../utils/tetromino_data.dart';

class PiecePreview extends StatelessWidget {
  final Piece? piece;

  const PiecePreview({super.key, this.piece});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
      ),
      child: piece == null
          ? const Center(child: Text('Empty'))
          : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                final x = index % 4;
                final y = index ~/ 4;
                final points = tetrominoData[piece!.type]!;
                final isPiece = points.contains(Point(x, y));
                return Container(
                  color: isPiece ? Colors.red : Colors.transparent,
                );
              },
            ),
    );
  }
}