import 'dart:math';

import '../models/piece.dart';

class BagGenerator {
  List<Tetromino> _bag = [];
  final Map<Tetromino, double>? pieceWeights;
  final Random _random = Random();

  BagGenerator({this.pieceWeights});

  Tetromino get next {
    if (_bag.isEmpty) {
      _fillBag();
    }
    return _bag.removeAt(0);
  }

  void _fillBag() {
    if (pieceWeights == null || pieceWeights!.isEmpty) {
      // Standard bag: all pieces equally weighted
      _bag = Tetromino.values.toList();
      _bag.shuffle(_random);
    } else {
      // Weighted bag: generate 14 pieces (2 bags worth) with weighted distribution
      _bag = _generateWeightedBag(14);
      _bag.shuffle(_random);
    }
  }

  List<Tetromino> _generateWeightedBag(int count) {
    final result = <Tetromino>[];

    // Calculate total weight
    double totalWeight = 0.0;
    for (final weight in pieceWeights!.values) {
      totalWeight += weight;
    }

    // Generate pieces based on weights
    for (int i = 0; i < count; i++) {
      result.add(_getWeightedPiece(totalWeight));
    }

    return result;
  }

  Tetromino _getWeightedPiece(double totalWeight) {
    double randomValue = _random.nextDouble() * totalWeight;
    double cumulativeWeight = 0.0;

    for (final entry in pieceWeights!.entries) {
      cumulativeWeight += entry.value;
      if (randomValue <= cumulativeWeight) {
        return entry.key;
      }
    }

    // Fallback (should never reach here)
    return Tetromino.values[_random.nextInt(Tetromino.values.length)];
  }

  /// Update the piece weights for changing difficulty
  void updateWeights(Map<Tetromino, double> newWeights) {
    if (pieceWeights != null) {
      pieceWeights!.clear();
      pieceWeights!.addAll(newWeights);
      // Clear the bag to force regeneration with new weights
      _bag.clear();
    }
  }
}
