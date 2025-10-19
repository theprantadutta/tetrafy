import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/bag_generator.dart';
import '../utils/tetromino_data.dart';
import 'difficulty_tier.dart';
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
  late BagGenerator _bagGenerator;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isPlaying = true;
  bool isGameOver = false;
  int linesClearedInLevel = 0; // Track lines cleared in current level
  int linesNeededForNextLevel = 10; // Lines needed to advance to next level (constant)
  int lastLineClearCount = 0; // Track how many lines were cleared in last clear
  List<int> rowsBeingCleared = []; // Track which rows are currently being cleared for animation

  // Difficulty system
  DifficultyTier _previousTier = DifficultyTier.easy;
  int piecesDropped = 0; // Track pieces for garbage row timing
  int rotationCount = 0; // Track rotations on current piece
  final List<int> garbageRows = []; // Track which rows are garbage rows

  // Session statistics
  DateTime? sessionStartTime;
  int sessionBlocksDropped = 0; // Accurate per-piece count
  int sessionPerfectClears = 0; // 4-line clears (Tetrises)
  int sessionMaxCombo = 0; // Best combo in this session
  int sessionCurrentCombo = 0; // Current active combo

  // Getters for difficulty system
  DifficultyTier get currentDifficultyTier => getDifficultyTier(level);
  DifficultyConfig get difficultyConfig => getDifficultyConfig(currentDifficultyTier);
  bool get shouldShowNextPiece => difficultyConfig.showNextPiece;
  int? get maxRotationsAllowed => difficultyConfig.maxRotations;
  bool get hasReachedRotationLimit => maxRotationsAllowed != null && rotationCount >= maxRotationsAllowed!;
  bool get tierChanged => currentDifficultyTier != _previousTier;

  GameModel({this.gameMode = GameMode.classic}) {
    // Initialize bag generator with difficulty weights
    final initialWeights = getDifficultyConfig(DifficultyTier.easy).pieceWeights;
    _bagGenerator = BagGenerator(pieceWeights: Map.from(initialWeights));

    // Start session tracking
    sessionStartTime = DateTime.now();

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
    piecesDropped = 0;
    rotationCount = 0;
    garbageRows.clear();
    _previousTier = DifficultyTier.easy;

    // Reset session stats
    sessionStartTime = DateTime.now();
    sessionBlocksDropped = 0;
    sessionPerfectClears = 0;
    sessionMaxCombo = 0;
    sessionCurrentCombo = 0;

    // Reset bag generator with easy weights
    final initialWeights = getDifficultyConfig(DifficultyTier.easy).pieceWeights;
    _bagGenerator.updateWeights(Map.from(initialWeights));

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
    rotationCount = 0; // Reset rotation counter for new piece
    piecesDropped++;

    // Check if we should spawn garbage row
    _checkAndSpawnGarbage();
  }

  void _checkAndSpawnGarbage() {
    final config = difficultyConfig;
    if (config.hasGarbageRows &&
        config.garbageFrequency != null &&
        piecesDropped % config.garbageFrequency! == 0) {
      _spawnGarbageRow();
    }
  }

  void _spawnGarbageRow() {
    // Check if there's room at the top
    if (grid[0].any((cell) => cell != null)) {
      // No room, game over
      isGameOver = true;
      isPlaying = false;
      return;
    }

    // Shift all rows up
    grid.insert(gridHeight, List.generate(gridWidth, (_) => null));
    grid.removeAt(0);

    // Create a garbage row with 1-3 random gaps
    final random = math.Random();
    final numGaps = 1 + random.nextInt(3); // 1-3 gaps
    final gapPositions = <int>{};

    while (gapPositions.length < numGaps) {
      gapPositions.add(random.nextInt(gridWidth));
    }

    // Fill the bottom row with garbage (gray blocks) except for gaps
    for (int x = 0; x < gridWidth; x++) {
      if (!gapPositions.contains(x)) {
        grid[gridHeight - 1][x] = Colors.grey.shade800; // Garbage block color
      }
    }

    // Track this as a garbage row
    garbageRows.add(gridHeight - 1);
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
    // Check rotation limit
    if (hasReachedRotationLimit) {
      return; // Cannot rotate anymore
    }

    final originalRotation = currentPiece.rotation;
    currentPiece.rotate();

    // If the rotation causes a collision, revert it
    if (!isValidPosition(currentPiece.position)) {
      currentPiece.rotation = originalRotation;
    } else {
      // Rotation successful, increment counter
      rotationCount++;
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

    // Track blocks dropped accurately
    sessionBlocksDropped++;

    // Check for line clears BEFORE clearing
    final linesClearedThisTurn = _countFullLines();

    _clearLines();

    // Update combo tracking based on whether lines were cleared
    if (linesClearedThisTurn == 0) {
      sessionCurrentCombo = 0; // Reset combo if no lines cleared
    }

    _spawnNewPiece();
  }

  int _countFullLines() {
    int count = 0;
    for (int y = gridHeight - 1; y >= 0; y--) {
      if (grid[y].every((cell) => cell != null)) {
        count++;
      }
    }
    return count;
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
    // First, identify which rows need to be cleared
    rowsBeingCleared.clear();
    for (int y = gridHeight - 1; y >= 0; y--) {
      if (grid[y].every((cell) => cell != null)) {
        rowsBeingCleared.add(y);
      }
    }

    // If there are rows to clear, mark the flag but don't clear immediately
    // The actual clearing will happen after animation
    if (rowsBeingCleared.isNotEmpty) {
      _linesClearedInLastMove = true;
      lastLineClearCount = rowsBeingCleared.length;
    }
  }

  // New method to actually clear the rows after animation
  void completeLineClear() {
    if (rowsBeingCleared.isEmpty) return;

    int linesClearedNow = rowsBeingCleared.length;

    // Sort rows in descending order to remove from bottom to top
    rowsBeingCleared.sort((a, b) => b.compareTo(a));

    for (int y in rowsBeingCleared) {
      linesCleared++;
      grid.removeAt(y);
      grid.insert(0, List.generate(gridWidth, (_) => null));
    }

    rowsBeingCleared.clear();
    _updateScore(linesClearedNow);
    _updateLevel();
  }

  void _updateScore(int lines) {
    // Track perfect clears (Tetrises - 4 lines at once)
    if (lines == 4) {
      sessionPerfectClears++;
    }

    // Track combo (increment and update max if lines were cleared)
    if (lines > 0) {
      sessionCurrentCombo++;
      if (sessionCurrentCombo > sessionMaxCombo) {
        sessionMaxCombo = sessionCurrentCombo;
      }
    }

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
      // Store previous level and tier to detect changes
      final previousLevel = level;
      _previousTier = currentDifficultyTier;

      // Check if we need to level up (constant 10 lines per level)
      if (linesClearedInLevel >= linesNeededForNextLevel) {
        level++;
        linesClearedInLevel -= linesNeededForNextLevel;
        // Constant requirement: always 10 lines per level
        linesNeededForNextLevel = 10;

        // Update bag generator weights if difficulty tier changed
        final newTier = currentDifficultyTier;
        if (newTier != _previousTier) {
          final newWeights = getDifficultyConfig(newTier).pieceWeights;
          _bagGenerator.updateWeights(Map.from(newWeights));
        }

        // For marathon mode, there's no game over, just keep leveling
        // Classic mode has no level cap (removed level 15 limit)
      }

      // Check if level increased
      if (level > previousLevel) {
        _levelCompletedInLastMove = true;
      }
    }
  }
}
