import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Screenshot(
          controller: screenshotController,
          child: AspectRatio(
            aspectRatio: GameModel.gridWidth / GameModel.gridHeight,
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameModel.gridWidth,
                  ),
                  itemCount: GameModel.gridWidth * GameModel.gridHeight,
                  itemBuilder: (context, index) {
                    final x = index % GameModel.gridWidth;
                    final y = index ~/ GameModel.gridWidth;
                    final piecePoints = widget.gameModel.getPiecePoints(
                      widget.gameModel.currentPiece.type,
                      widget.gameModel.currentPiece.rotation,
                      widget.gameModel.currentPiece.position,
                    );
                    final isPiece = piecePoints.contains(Point(x, y));
                    final color = isPiece
                        ? Colors.red
                        : widget.gameModel.grid[y][x];
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: color == null ? 0 : 1,
                      child: _buildBlock(color),
                    );
                  },
                ),
                if (widget.gameModel.linesCleared > 0)
                  CircularParticle(
                    key: UniqueKey(),
                    awayRadius: 120,
                    numberOfParticles: 500,
                    speedOfParticles: 2,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    onTapAnimation: false,
                    particleColor: Colors.white.withAlpha(200),
                    awayAnimationDuration: const Duration(milliseconds: 400),
                    maxParticleSize: 4,
                    isRandomColor: true,
                    awayAnimationCurve: Curves.fastOutSlowIn,
                    enableHover: false,
                    connectDots: false,
                  ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final Uint8List? image = await screenshotController.capture();
            if (image != null) {
              final directory = await getApplicationDocumentsDirectory();
              final imagePath = await File(
                '${directory.path}/screenshot.png',
              ).writeAsBytes(image);
              await Share.shareXFiles([
                XFile(imagePath.path),
              ], text: 'Check out my score on Tetras!');
            }
          },
          child: const Text('Share Score'),
        ),
      ],
    );
  }

  Widget _buildBlock(Color? color) {
    switch (widget.blockSkin) {
      case BlockSkin.flat:
        return Container(color: color, margin: const EdgeInsets.all(1));
      case BlockSkin.glossy:
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.5), Colors.transparent],
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
