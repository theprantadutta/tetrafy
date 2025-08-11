import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/point.dart';
import '../utils/tetromino_data.dart';

class PiecePreview extends StatefulWidget {
  final Piece? piece;
  final Color color;

  const PiecePreview({super.key, this.piece, this.color = Colors.red});

  @override
  State<PiecePreview> createState() => _PiecePreviewState();
}

class _PiecePreviewState extends State<PiecePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 5.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: _animation.value,
                spreadRadius: _animation.value,
              ),
            ],
          ),
          child: widget.piece == null
              ? const Center(child: Text('Empty'))
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    final x = index % 4;
                    final y = index ~/ 4;
                    final points = tetrominoData[widget.piece!.type]!;
                    final isPiece = points.contains(Point(x, y));
                    return Container(
                      color: isPiece ? widget.color : Colors.transparent,
                    );
                  },
                ),
        );
      },
    );
  }
}