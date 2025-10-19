import 'dart:math';

import '../models/piece.dart';

/// Represents different difficulty tiers in the game
enum DifficultyTier {
  easy,
  medium,
  hard,
  expert,
  insane,
}

/// Configuration for each difficulty tier
class DifficultyConfig {
  final DifficultyTier tier;
  final String displayName;
  final Map<Tetromino, double> pieceWeights;
  final double speedMultiplier;
  final bool hasGarbageRows;
  final int? garbageFrequency; // Spawn garbage every X pieces (null = no garbage)
  final bool showNextPiece;
  final int? maxRotations; // null = unlimited rotations

  const DifficultyConfig({
    required this.tier,
    required this.displayName,
    required this.pieceWeights,
    required this.speedMultiplier,
    this.hasGarbageRows = false,
    this.garbageFrequency,
    this.showNextPiece = true,
    this.maxRotations,
  });
}

/// Get difficulty tier based on current level
DifficultyTier getDifficultyTier(int level) {
  if (level <= 5) return DifficultyTier.easy;
  if (level <= 10) return DifficultyTier.medium;
  if (level <= 15) return DifficultyTier.hard;
  if (level <= 20) return DifficultyTier.expert;
  return DifficultyTier.insane;
}

/// Get configuration for a specific difficulty tier
DifficultyConfig getDifficultyConfig(DifficultyTier tier) {
  switch (tier) {
    case DifficultyTier.easy:
      return const DifficultyConfig(
        tier: DifficultyTier.easy,
        displayName: 'EASY',
        speedMultiplier: 1.0, // 500ms base
        pieceWeights: {
          Tetromino.I: 2.0,  // More I-pieces (easiest)
          Tetromino.O: 1.8,  // More O-pieces (simple)
          Tetromino.T: 1.2,  // Slightly more T-pieces
          Tetromino.L: 1.0,  // Normal L-pieces
          Tetromino.J: 1.0,  // Normal J-pieces
          Tetromino.S: 0.5,  // Fewer S-pieces (harder)
          Tetromino.Z: 0.5,  // Fewer Z-pieces (harder)
        },
        hasGarbageRows: false,
        showNextPiece: true,
        maxRotations: null, // Unlimited
      );

    case DifficultyTier.medium:
      return const DifficultyConfig(
        tier: DifficultyTier.medium,
        displayName: 'MEDIUM',
        speedMultiplier: 0.6, // Faster
        pieceWeights: {
          Tetromino.I: 1.0,  // Balanced
          Tetromino.O: 1.0,
          Tetromino.T: 1.0,
          Tetromino.L: 1.0,
          Tetromino.J: 1.0,
          Tetromino.S: 1.0,
          Tetromino.Z: 1.0,
        },
        hasGarbageRows: false,
        showNextPiece: true,
        maxRotations: null,
      );

    case DifficultyTier.hard:
      return const DifficultyConfig(
        tier: DifficultyTier.hard,
        displayName: 'HARD',
        speedMultiplier: 0.35, // Much faster
        pieceWeights: {
          Tetromino.I: 0.7,  // Fewer I-pieces
          Tetromino.O: 1.0,  // Normal O-pieces
          Tetromino.T: 1.2,  // More T-pieces
          Tetromino.L: 1.2,  // More L-pieces
          Tetromino.J: 1.2,  // More J-pieces
          Tetromino.S: 1.5,  // More S-pieces (harder)
          Tetromino.Z: 1.5,  // More Z-pieces (harder)
        },
        hasGarbageRows: true,
        garbageFrequency: 18, // Every 18 pieces
        showNextPiece: true,
        maxRotations: null,
      );

    case DifficultyTier.expert:
      return const DifficultyConfig(
        tier: DifficultyTier.expert,
        displayName: 'EXPERT',
        speedMultiplier: 0.2, // Very fast
        pieceWeights: {
          Tetromino.I: 0.4,  // Very few I-pieces
          Tetromino.O: 0.8,  // Fewer O-pieces
          Tetromino.T: 1.5,  // Many T-pieces
          Tetromino.L: 1.3,  // Many L-pieces
          Tetromino.J: 1.3,  // Many J-pieces
          Tetromino.S: 2.0,  // Heavy S-pieces
          Tetromino.Z: 2.0,  // Heavy Z-pieces
        },
        hasGarbageRows: true,
        garbageFrequency: 12, // Every 12 pieces (more frequent)
        showNextPiece: false, // No next piece preview!
        maxRotations: null,
      );

    case DifficultyTier.insane:
      return const DifficultyConfig(
        tier: DifficultyTier.insane,
        displayName: 'INSANE',
        speedMultiplier: 0.2, // Capped at max speed
        pieceWeights: {
          Tetromino.I: 0.2,  // Extremely rare I-pieces
          Tetromino.O: 0.6,  // Very few O-pieces
          Tetromino.T: 1.8,  // Heavy T-pieces
          Tetromino.L: 1.5,  // Heavy L-pieces
          Tetromino.J: 1.5,  // Heavy J-pieces
          Tetromino.S: 2.5,  // Extreme S-pieces
          Tetromino.Z: 2.5,  // Extreme Z-pieces
        },
        hasGarbageRows: true,
        garbageFrequency: 10, // Every 10 pieces (very frequent)
        showNextPiece: false, // No next piece preview
        maxRotations: 2, // Maximum 2 rotations per piece!
      );
  }
}

/// Calculate game speed in milliseconds based on level
int calculateGameSpeed(int level) {
  // Formula: 500ms * (0.9 ^ (level - 1)) with minimum of 100ms
  final baseSpeed = 500.0;
  final calculated = baseSpeed * pow(0.9, level - 1);
  return calculated.round().clamp(100, 500);
}
