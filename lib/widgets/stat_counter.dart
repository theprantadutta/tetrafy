import 'package:flutter/material.dart';

/// An animated counter that animates to a target value
class StatCounter extends StatefulWidget {
  final int targetValue;
  final String? label;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final Duration animationDuration;
  final Color? glowColor;

  const StatCounter({
    super.key,
    required this.targetValue,
    this.label,
    this.valueStyle,
    this.labelStyle,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.glowColor,
  });

  @override
  State<StatCounter> createState() => _StatCounterState();
}

class _StatCounterState extends State<StatCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(StatCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation() {
    _animation = IntTween(
      begin: _currentValue,
      end: widget.targetValue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
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
        _currentValue = _animation.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: widget.labelStyle ??
                    theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              _currentValue.toString(),
              style: widget.valueStyle ??
                  theme.textTheme.displaySmall?.copyWith(
                    color: glowColor,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: glowColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
            ),
          ],
        );
      },
    );
  }
}
