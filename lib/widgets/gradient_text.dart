import 'package:flutter/material.dart';

/// Text with gradient effect and optional glow
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color>? gradientColors;
  final bool showGlow;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradientColors,
    this.showGlow = false,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
        ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? theme.textTheme.displayMedium)?.copyWith(
          color: Colors.white,
          shadows: showGlow
              ? [
                  Shadow(
                    color: colors[0].withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                  Shadow(
                    color: colors[1].withValues(alpha: 0.5),
                    blurRadius: 30,
                  ),
                ]
              : null,
        ),
        textAlign: textAlign,
      ),
    );
  }
}

/// Animated gradient text that shifts colors
class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color>? gradientColors;
  final bool showGlow;
  final Duration animationDuration;
  final TextAlign? textAlign;

  const AnimatedGradientText({
    super.key,
    required this.text,
    this.style,
    this.gradientColors,
    this.showGlow = true,
    this.animationDuration = const Duration(seconds: 3),
    this.textAlign,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
        ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: colors,
            tileMode: TileMode.mirror,
            transform: GradientRotation(_animation.value * 6.28), // 2π radians
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: (widget.style ?? theme.textTheme.displayMedium)?.copyWith(
              color: Colors.white,
              shadows: widget.showGlow
                  ? [
                      Shadow(
                        color: colors[0].withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: colors[1].withValues(alpha: 0.5),
                        blurRadius: 30,
                      ),
                    ]
                  : null,
            ),
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}
