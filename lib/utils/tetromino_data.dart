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
    [Point(0, 1), Point(1, 1), Point(2, 1), Point(3, 1)],
    [Point(2, 0), Point(2, 1), Point(2, 2), Point(2, 3)],
    [Point(0, 2), Point(1, 2), Point(2, 2), Point(3, 2)],
    [Point(1, 0), Point(1, 1), Point(1, 2), Point(1, 3)],
  ],
  Tetromino.O: [
    [Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 1)],
  ],
  Tetromino.T: [
    [Point(1, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(1, 1), Point(2, 1), Point(1, 2)],
    [Point(0, 1), Point(1, 1), Point(2, 1), Point(1, 2)],
    [Point(1, 0), Point(0, 1), Point(1, 1), Point(1, 2)],
  ],
  Tetromino.S: [
    [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)],
    [Point(1, 0), Point(1, 1), Point(2, 1), Point(2, 2)],
    [Point(1, 1), Point(2, 1), Point(0, 2), Point(1, 2)],
    [Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 2)],
  ],
  Tetromino.Z: [
    [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)],
    [Point(2, 0), Point(1, 1), Point(2, 1), Point(1, 2)],
    [Point(0, 1), Point(1, 1), Point(1, 2), Point(2, 2)],
    [Point(1, 0), Point(0, 1), Point(1, 1), Point(0, 2)],
  ],
  Tetromino.J: [
    [Point(0, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(2, 0), Point(1, 1), Point(1, 2)],
    [Point(0, 1), Point(1, 1), Point(2, 1), Point(2, 2)],
    [Point(1, 0), Point(1, 1), Point(0, 2), Point(1, 2)],
  ],
  Tetromino.L: [
    [Point(2, 0), Point(0, 1), Point(1, 1), Point(2, 1)],
    [Point(1, 0), Point(1, 1), Point(1, 2), Point(2, 2)],
    [Point(0, 1), Point(1, 1), Point(2, 1), Point(0, 2)],
    [Point(0, 0), Point(1, 0), Point(1, 1), Point(1, 2)],
  ],
};