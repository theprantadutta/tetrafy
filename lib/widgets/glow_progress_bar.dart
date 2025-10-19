import 'package:flutter/material.dart';

/// A progress bar with gradient fill and glow effect
class GlowProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool showGlow;
  final String? label;

  const GlowProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.borderRadius = 10,
    this.backgroundColor,
    this.gradientColors,
    this.showGlow = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
        ];
    final bgColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Progress fill
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: showGlow
                          ? [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated progress bar that animates value changes
class AnimatedGlowProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool showGlow;
  final String? label;
  final Duration animationDuration;

  const AnimatedGlowProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.borderRadius = 10,
    this.backgroundColor,
    this.gradientColors,
    this.showGlow = true,
    this.label,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedGlowProgressBar> createState() =>
      _AnimatedGlowProgressBarState();
}

class _AnimatedGlowProgressBarState extends State<AnimatedGlowProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0.0;

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
  void didUpdateWidget(AnimatedGlowProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation() {
    _animation = Tween<double>(
      begin: _currentValue,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        _currentValue = _animation.value;
        return GlowProgressBar(
          value: _currentValue,
          height: widget.height,
          borderRadius: widget.borderRadius,
          backgroundColor: widget.backgroundColor,
          gradientColors: widget.gradientColors,
          showGlow: widget.showGlow,
          label: widget.label,
        );
      },
    );
  }
}
