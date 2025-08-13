import 'package:flutter/material.dart';

import '../models/block_skin.dart';
import '../models/game_model.dart';
import '../models/point.dart';

class GameBoard extends StatefulWidget {
  final GameModel gameModel;
  final BlockSkin blockSkin;

  const GameBoard({
    super.key,
    required this.gameModel,
    this.blockSkin = BlockSkin.flat,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Point<int> _getGhostPosition() {
    Point<int> ghostPosition = widget.gameModel.currentPiece.position;
    while (widget.gameModel.isValidPosition(
        Point(ghostPosition.x, ghostPosition.y + 1))) {
      ghostPosition = Point(ghostPosition.x, ghostPosition.y + 1);
    }
    return ghostPosition;
  }

  @override
  Widget build(BuildContext context) {
    final ghostPosition = _getGhostPosition();
    final ghostPoints = widget.gameModel.getPiecePoints(
      widget.gameModel.currentPiece.type,
      widget.gameModel.currentPiece.rotation,
      ghostPosition,
    );

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: GameModel.gridWidth,
      ),
      itemCount: GameModel.gridWidth * GameModel.gridHeight,
      itemBuilder: (context, index) {
        final x = index % GameModel.gridWidth;
        final y = index ~/ GameModel.gridWidth;
        
        // Get the current piece's points
        final piecePoints = widget.gameModel.getPiecePoints(
          widget.gameModel.currentPiece.type,
          widget.gameModel.currentPiece.rotation,
          widget.gameModel.currentPiece.position,
        );
        
        // Check if the current cell is part of the active piece
        final isPiece = piecePoints.contains(Point(x, y));
        
        // Check if the current cell is part of the ghost piece
        final isGhost = ghostPoints.contains(Point(x, y));
        
        // Determine the color of the cell
        Color? color;
        if (isPiece) {
          // Use the color of the active piece
          color = widget.gameModel.currentPiece.color;
        } else if (isGhost) {
          // Use a transparent version of the piece color for the ghost
          color = widget.gameModel.currentPiece.color.withValues(alpha: 0.3);
        } else {
          // Use the color from the grid (placed pieces or empty)
          color = widget.gameModel.grid[y][x];
        }
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: color == null && !isGhost ? 0 : 1,
          child: _buildBlock(color, isGhost: isGhost && !isPiece),
        );
      },
    );
  }

  Widget _buildBlock(Color? color, {bool isGhost = false}) {
    if (color == null && !isGhost) {
      return const SizedBox(); // Return an empty widget for empty cells
    }
    
    if (isGhost) {
      // Draw ghost piece as an outline
      return Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(
            color: color ?? Colors.grey,
            width: 2,
          ),
        ),
      );
    }
    
    switch (widget.blockSkin) {
      case BlockSkin.flat:
        return Container(
          margin: const EdgeInsets.all(1),
          color: color,
        );
      case BlockSkin.glossy:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: 0.5), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case BlockSkin.pixelArt:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2),
          ),
        );
    }
  }
}