import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../models/point.dart';

class GameBoard extends StatelessWidget {
  final GameModel gameModel;

  const GameBoard({super.key, required this.gameModel});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: GameModel.gridWidth / GameModel.gridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GameModel.gridWidth,
        ),
        itemCount: GameModel.gridWidth * GameModel.gridHeight,
        itemBuilder: (context, index) {
          final x = index % GameModel.gridWidth;
          final y = index ~/ GameModel.gridWidth;
          final piecePoints = gameModel.currentPiece != null
              ? gameModel.getPiecePoints(
                  gameModel.currentPiece.type,
                  gameModel.currentPiece.rotation,
                  gameModel.currentPiece.position,
                )
              : [];
          final isPiece = piecePoints.contains(Point(x, y));
          final color = isPiece ? Colors.red : gameModel.grid[y][x];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: color == null ? 0 : 1,
            child: Container(
              color: color,
              margin: const EdgeInsets.all(1),
            ),
          );
        },
      ),
    );
  }
}