import 'package:flutter/material.dart';

import '../utils/tetromino_data.dart';
import 'point.dart';

enum Tetromino { I, O, T, S, Z, J, L }

class Piece {
  Tetromino type;
  Color get color => tetrominoColors[type]!;
  int rotation;
  Point<int> position;

  Piece({required this.type, this.rotation = 0, required this.position});

  // TODO: Add methods for rotation and movement
}
