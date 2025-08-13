import 'package:flutter/material.dart';

import '../utils/bag_generator.dart';
import '../utils/tetromino_data.dart';
import 'game_mode.dart';
import 'piece.dart';
import 'point.dart';

class GameModel {
  final GameMode gameMode;
  static const int gridWidth = 10;
  static const int gridHeight = 20;

  List<List<Color?>> grid = List.generate(
    gridHeight,
    (_) => List.generate(gridWidth, (_) => null),
  );

  late Piece currentPiece;
  Piece? _holdPiece;
  late Piece nextPiece;

  Piece? get heldPiece => _holdPiece;
  final BagGenerator _bagGenerator = BagGenerator();
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isPlaying = true;
  bool isGameOver = false;
  int linesClearedInLevel = 0; // Track lines cleared in current level
  int linesNeededForNextLevel = 10; // Lines needed to advance to next level
  int lastLineClearCount = 0; // Track how many lines were cleared in last clear

  GameModel({this.gameMode = GameMode.classic}) {
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
    linesClearedInLevel = 0;
    linesNeededForNextLevel = 10;
    isGameOver = false;
    isPlaying = true;
    _holdPiece = null;
    _spawnNewPiece();
  }

  bool _hasHeld = false;
  bool _linesClearedInLastMove = false; // Track if lines were cleared in the last move
  bool _levelCompletedInLastMove = false; // Track if level was completed in the last move

  // Getters to check if lines were cleared or level completed
  bool get linesClearedInLastMove => _linesClearedInLastMove;
  bool get levelCompletedInLastMove => _levelCompletedInLastMove;

  // Reset the flags after checking them
  void resetMoveFlags() {
    _linesClearedInLastMove = false;
    _levelCompletedInLastMove = false;
  }

  void hold() {
    if (_hasHeld) return; // Can only hold once per piece
    
    if (_holdPiece == null) {
      _holdPiece = currentPiece;
      _spawnNewPiece();
    } else {
      final temp = currentPiece;
      currentPiece = _holdPiece!;
      currentPiece.position = Point(gridWidth ~/ 2 - 1, 0);
      _holdPiece = temp;
    }
    _hasHeld = true;
  }

  void _spawnNewPiece() {
    currentPiece = nextPiece;
    currentPiece.position = Point(gridWidth ~/ 2 - 1, 0);
    nextPiece = Piece(type: _bagGenerator.next, position: Point(0, 0));
    if (!isValidPosition(currentPiece.position)) {
      isGameOver = true;
      isPlaying = false;
    }
    _hasHeld = false; // Reset hold flag for new piece
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
    final originalRotation = currentPiece.rotation;
    currentPiece.rotate();
    
    // If the rotation causes a collision, revert it
    if (!isValidPosition(currentPiece.position)) {
      currentPiece.rotation = originalRotation;
    }
  }

  void hardDrop() {
    while (isValidPosition(
      Point(currentPiece.position.x, currentPiece.position.y + 1),
    )) {
      currentPiece.position = Point(
        currentPiece.position.x,
        currentPiece.position.y + 1,
      );
    }
    _placePiece();
  }

  void _move(int dx, int dy) {
    final newPosition = Point(
      currentPiece.position.x + dx,
      currentPiece.position.y + dy,
    );
    if (isValidPosition(newPosition)) {
      currentPiece.position = newPosition;
    } else {
      if (dy > 0) {
        _placePiece();
      }
    }
  }

  void _placePiece() {
    final points = getPiecePoints(
      currentPiece.type,
      currentPiece.rotation,
      currentPiece.position,
    );
    for (final point in points) {
      if (point.y >= 0) {
        grid[point.y][point.x] = currentPiece.color;
      }
    }
    _clearLines();
    _spawnNewPiece();
  }

  bool isValidPosition(Point<int> position) {
    final points = getPiecePoints(
      currentPiece.type,
      currentPiece.rotation,
      position,
    );
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

  List<Point<int>> getPiecePoints(
    Tetromino type,
    int rotation,
    Point<int> position,
  ) {
    final points = tetrominoData[type]![rotation % 4];
    return points
        .map((p) => Point(p.x + position.x, p.y + position.y))
        .toList();
  }

  void _clearLines() {
    int linesClearedNow = 0;
    for (int y = gridHeight - 1; y >= 0; y--) {
      if (grid[y].every((cell) => cell != null)) {
        linesCleared++;
        linesClearedNow++;
        grid.removeAt(y);
        grid.insert(0, List.generate(gridWidth, (_) => null));
        // Don't decrement y since we've removed a row
        y++; // This will be decremented by the loop, so it stays the same
      }
    }
    if (linesClearedNow > 0) {
      _linesClearedInLastMove = true;
      lastLineClearCount = linesClearedNow;
      _updateScore(linesClearedNow);
      _updateLevel();
    }
  }

  void _updateScore(int lines) {
    // Scoring based on original Nintendo scoring system
    int points = 0;
    switch (lines) {
      case 1:
        points = 100 * level;
        break;
      case 2:
        points = 300 * level;
        break;
      case 3:
        points = 500 * level;
        break;
      case 4:
        points = 800 * level;
        break;
    }
    score += points;

    if (gameMode == GameMode.classic) {
      linesClearedInLevel += lines;
    } else if (gameMode == GameMode.sprint) {
      if (linesCleared >= 40) {
        isGameOver = true;
        isPlaying = false;
      }
    } else if (gameMode == GameMode.marathon) {
      // No game over condition, just keep playing
      linesClearedInLevel += lines;
    } else if (gameMode == GameMode.zen) {
      // No timer, no score, no levels
    }
  }

  void _updateLevel() {
    if (gameMode == GameMode.classic || gameMode == GameMode.marathon) {
      // Store previous level to detect level up
      final previousLevel = level;
      
      // Check if we need to level up
      if (linesClearedInLevel >= linesNeededForNextLevel) {
        level++;
        linesClearedInLevel -= linesNeededForNextLevel;
        linesNeededForNextLevel = level * 10; // Increase requirement for next level
        
        // For marathon mode, there's no game over, just keep leveling
        if (gameMode == GameMode.classic && level > 15) {
          // End game after level 15 in classic mode
          isGameOver = true;
          isPlaying = false;
        }
      }
      
      // Check if level increased
      if (level > previousLevel) {
        _levelCompletedInLastMove = true;
      }
    }
  }
}
