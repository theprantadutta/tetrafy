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

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GameModel.gridWidth,
            childAspectRatio: 1.0,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
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
      },
    );
  }

  Widget _buildBlock(Color? color, {bool isGhost = false}) {
    if (color == null && !isGhost) {
      return const SizedBox(); // Return an empty widget for empty cells
    }

    if (isGhost) {
      // Draw ghost piece with animated glow outline
      return Container(
        margin: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: (color ?? Colors.grey).withValues(alpha: 0.6),
            width: 2,
          ),
          // Subtle fill for better visibility
          color: (color ?? Colors.grey).withValues(alpha: 0.08),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.grey).withValues(alpha: 0.3),
              blurRadius: 3,
              spreadRadius: 0.5,
            ),
          ],
        ),
      );
    }

    switch (widget.blockSkin) {
      case BlockSkin.flat:
        return Container(
          margin: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            // Brighten the color slightly
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              // Stronger glow for visibility
              BoxShadow(
                color: (color ?? Colors.white).withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              // Inner highlight
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 1,
                spreadRadius: -0.5,
              ),
            ],
            // Add subtle gradient for depth
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (color ?? Colors.white).withValues(alpha: 1.0),
                (color ?? Colors.white).withValues(alpha: 0.85),
              ],
            ),
          ),
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

      case BlockSkin.neon:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.3),
            border: Border.all(
              color: color ?? Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color?.withValues(alpha: 0.8) ?? Colors.white,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );

      case BlockSkin.holographic:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color ?? Colors.white,
                color?.withValues(alpha: 0.5) ?? Colors.white,
                Colors.white.withValues(alpha: 0.3),
                color ?? Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        );

      case BlockSkin.crystal:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.6),
                (color ?? Colors.white).withValues(alpha: 0.8),
                color ?? Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.white).withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        );

      case BlockSkin.gem:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.8),
                color ?? Colors.white,
                (color ?? Colors.white).withValues(alpha: 0.6),
              ],
              center: const Alignment(-0.3, -0.3),
            ),
            border: Border.all(
              color: (color ?? Colors.white).withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.white).withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );

      case BlockSkin.glass:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: 0.2),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.4),
                (color ?? Colors.white).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: (color ?? Colors.white).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        );
    }
  }
}