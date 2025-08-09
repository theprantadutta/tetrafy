import 'package:flutter/material.dart';
import 'piece.dart';
import 'point.dart';
import '../utils/bag_generator.dart';
import '../utils/tetromino_data.dart';

class GameModel {
  static const int gridWidth = 10;
  static const int gridHeight = 20;

  List<List<Color?>> grid = List.generate(
    gridHeight,
    (_) => List.generate(gridWidth, (_) => null),
  );

  late Piece currentPiece;
  Piece? holdPiece;
  late Piece nextPiece;
  final BagGenerator _bagGenerator = BagGenerator();
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isPlaying = true;
  bool isGameOver = false;

  GameModel() {
    nextPiece = Piece(type: _bagGenerator.next, position: Point(0, 0));
    _spawnNewPiece();
  }

  void togglePause() {
    isPlaying = !isPlaying;
  }

  void restart() {
    grid = List.generate(
      gridHeight,
      (_) => List.generate(gridWidth, (_) => null),
    );
    score = 0;
    level = 1;
    linesCleared = 0;
    isGameOver = false;
    isPlaying = true;
    holdPiece = null;
    _spawnNewPiece();
  }

  void hold() {
    if (holdPiece == null) {
      holdPiece = currentPiece;
      _spawnNewPiece();
    } else {
      final temp = currentPiece;
      currentPiece = holdPiece!;
      holdPiece = temp;
    }
  }

  void _spawnNewPiece() {
    currentPiece = nextPiece;
    currentPiece.position = Point(gridWidth ~/ 2 - 1, 0);
    nextPiece = Piece(type: _bagGenerator.next, position: Point(0, 0));
    if (!isValidPosition(currentPiece.position)) {
      isGameOver = true;
      isPlaying = false;
    }
  }

  void moveLeft() {
    _move(-1, 0);
  }

  void moveRight() {
    _move(1, 0);
  }

  void moveDown() {
    _move(0, 1);
  }

  void rotate() {
    // TODO: Implement rotation
  }

  void _move(int dx, int dy) {
    final newPosition = Point(currentPiece.position.x + dx, currentPiece.position.y + dy);
    if (isValidPosition(newPosition)) {
      currentPiece.position = newPosition;
    }
  }

  bool isValidPosition(Point<int> position) {
    final points = getPiecePoints(currentPiece.type, currentPiece.rotation, position);
    for (final point in points) {
      if (point.x < 0 || point.x >= gridWidth || point.y >= gridHeight) {
        return false;
      }
      if (point.y >= 0 && grid[point.y][point.x] != null) {
        return false;
      }
    }
    return true;
  }

  List<Point<int>> getPiecePoints(Tetromino type, int rotation, Point<int> position) {
    final points = tetrominoData[type]![rotation % 4];
    return points.map((p) => Point(p.x + position.x, p.y + position.y)).toList();
  }

  void _clearLines() {
    for (int y = gridHeight - 1; y >= 0; y--) {
      if (grid[y].every((cell) => cell != null)) {
        linesCleared++;
        grid.removeAt(y);
        grid.insert(0, List.generate(gridWidth, (_) => null));
        _updateScore(1);
      }
    }
  }

  void _updateScore(int lines) {
    score += lines * 100;
    if (linesCleared >= level * 10) {
      level++;
    }
  }
}