import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/point.dart';

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.I: Colors.cyan,
  Tetromino.O: Colors.yellow,
  Tetromino.T: Colors.purple,
  Tetromino.S: Colors.green,
  Tetromino.Z: Colors.red,
  Tetromino.J: Colors.blue,
  Tetromino.L: Colors.orange,
};

const Map<Tetromino, List<List<Point<int>>>> tetrominoData = {
  Tetromino.I: [
    [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(3, 1)],
    [const Point(2, 0), const Point(2, 1), const Point(2, 2), const Point(2, 3)],
    [const Point(0, 2), const Point(1, 2), const Point(2, 2), const Point(3, 2)],
    [const Point(1, 0), const Point(1, 1), const Point(1, 2), const Point(1, 3)],
  ],
  Tetromino.O: [
    [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(2, 1)],
  ],
  Tetromino.T: [
    [const Point(1, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
    [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
    [const Point(1, 0), const Point(0, 1), const Point(1, 1), const Point(1, 2)],
  ],
  Tetromino.S: [
    [const Point(1, 0), const Point(2, 0), const Point(0, 1), const Point(1, 1)],
    [const Point(1, 0), const Point(1, 1), const Point(2, 1), const Point(2, 2)],
    [const Point(1, 1), const Point(2, 1), const Point(0, 2), const Point(1, 2)],
    [const Point(0, 0), const Point(0, 1), const Point(1, 1), const Point(1, 2)],
  ],
  Tetromino.Z: [
    [const Point(0, 0), const Point(1, 0), const Point(1, 1), const Point(2, 1)],
    [const Point(2, 0), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
    [const Point(0, 1), const Point(1, 1), const Point(1, 2), const Point(2, 2)],
    [const Point(1, 0), const Point(0, 1), const Point(1, 1), const Point(0, 2)],
  ],
  Tetromino.J: [
    [const Point(0, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(1, 2)],
    [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(2, 2)],
    [const Point(1, 0), const Point(1, 1), const Point(0, 2), const Point(1, 2)],
  ],
  Tetromino.L: [
    [const Point(2, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
    [const Point(1, 0), const Point(1, 1), const Point(1, 2), const Point(2, 2)],
    [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(0, 2)],
    [const Point(0, 0), const Point(1, 0), const Point(1, 1), const Point(1, 2)],
  ],
};