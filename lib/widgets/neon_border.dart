import 'package:flutter/material.dart';

/// An animated neon glowing border widget
class NeonBorder extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double borderRadius;
  final double borderWidth;
  final bool isAnimated;
  final Duration animationDuration;

  const NeonBorder({
    super.key,
    required this.child,
    this.glowColor,
    this.borderRadius = 15.0,
    this.borderWidth = 2.0,
    this.isAnimated = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<NeonBorder> createState() => _NeonBorderState();
}

class _NeonBorderState extends State<NeonBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glowColor = widget.glowColor ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: glowColor,
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.6 * _animation.value),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
              BoxShadow(
                color: glowColor.withValues(alpha: 0.3 * _animation.value),
                blurRadius: 20 * _animation.value,
                spreadRadius: 4 * _animation.value,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.child,
          ),
        );
      },
    );
  }
}
