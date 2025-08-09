import 'dart:math';
import '../models/piece.dart';

class BagGenerator {
  List<Tetromino> _bag = [];

  Tetromino get next {
    if (_bag.isEmpty) {
      _fillBag();
    }
    return _bag.removeAt(0);
  }

  void _fillBag() {
    _bag = Tetromino.values.toList();
    _bag.shuffle(Random());
  }
}