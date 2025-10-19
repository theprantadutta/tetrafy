import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A theme-aware animated background that adapts to the current theme
class ThemedBackground extends StatefulWidget {
  final String themeName;

  const ThemedBackground({
    super.key,
    this.themeName = 'aurora',
  });

  @override
  State<ThemedBackground> createState() => _ThemedBackgroundState();
}

class _ThemedBackgroundState extends State<ThemedBackground> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Return theme-specific background
    switch (widget.themeName) {
      case 'aurora':
        return AuroraBackground(colorScheme: theme.colorScheme);
      case 'synthwave':
        return SynthwaveBackground(colorScheme: theme.colorScheme);
      case 'cosmic':
        return CosmicBackground(colorScheme: theme.colorScheme);
      case 'neonTokyo':
        return NeonTokyoBackground(colorScheme: theme.colorScheme);
      case 'oceanDeep':
        return OceanDeepBackground(colorScheme: theme.colorScheme);
      case 'sunsetArcade':
        return SunsetArcadeBackground(colorScheme: theme.colorScheme);
      default:
        return AuroraBackground(colorScheme: theme.colorScheme);
    }
  }
}

/// Aurora (Northern Lights) Background
class AuroraBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const AuroraBackground({super.key, required this.colorScheme});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuroraPainter(
            animation: _controller.value,
            colors: [
              widget.colorScheme.primary,
              widget.colorScheme.secondary,
              widget.colorScheme.tertiary,
            ],
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final Color backgroundColor;

  _AuroraPainter({
    required this.animation,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw flowing aurora waves
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[i].withValues(alpha: 0.3),
            colors[i].withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final path = Path();
      final waveOffset = animation * 2 * math.pi + i * math.pi / 3;

      path.moveTo(0, size.height * 0.3);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.3 +
            math.sin((x / size.width) * 4 * math.pi + waveOffset) * 50 +
            math.sin((x / size.width) * 2 * math.pi + waveOffset * 0.5) * 30;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Synthwave Background (Grid-based)
class SynthwaveBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const SynthwaveBackground({super.key, required this.colorScheme});

  @override
  State<SynthwaveBackground> createState() => _SynthwaveBackgroundState();
}

class _SynthwaveBackgroundState extends State<SynthwaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SynthwavePainter(
            animation: _controller.value,
            primaryColor: widget.colorScheme.primary,
            secondaryColor: widget.colorScheme.secondary,
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _SynthwavePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;

  _SynthwavePainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [
            backgroundColor,
            Color.lerp(backgroundColor, primaryColor, 0.2)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw perspective grid
    final gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines (perspective) - seamless loop
    final numHorizontalLines = 15;
    final lineSpacing = size.height * 0.5 / numHorizontalLines;

    // Draw extra lines to ensure seamless loop
    for (int i = -1; i < numHorizontalLines + 1; i++) {
      final offset = animation * lineSpacing;
      final baseY = size.height * 0.5 + (i * lineSpacing);
      final y = baseY + offset;

      // Only draw if visible
      if (y >= size.height * 0.5 && y <= size.height) {
        final progress = (y - size.height * 0.5) / (size.height * 0.5);
        final scale = 1.0 - progress * 0.8;
        final lineWidth = size.width * scale;
        final xOffset = (size.width - lineWidth) / 2;

        canvas.drawLine(
          Offset(xOffset, y),
          Offset(xOffset + lineWidth, y),
          gridPaint,
        );
      }
    }

    // Vertical lines (perspective)
    final numVerticalLines = 20;
    for (int i = 0; i < numVerticalLines; i++) {
      final xRatio = i / (numVerticalLines - 1);
      final startX = size.width * xRatio;
      final vanishingY = size.height * 0.5;

      canvas.drawLine(
        Offset(startX, vanishingY),
        Offset(size.width * 0.5 + (startX - size.width * 0.5) * 0.1, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Cosmic Background (Starfield)
class CosmicBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const CosmicBackground({super.key, required this.colorScheme});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    stars = List.generate(100, (index) => _Star());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CosmicPainter(
            animation: _controller.value,
            stars: stars,
            colors: [
              widget.colorScheme.primary,
              widget.colorScheme.secondary,
              widget.colorScheme.tertiary,
            ],
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double twinkleOffset;

  _Star()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        size = math.Random().nextDouble() * 2 + 1,
        speed = math.Random().nextDouble() * 0.5 + 0.1,
        twinkleOffset = math.Random().nextDouble() * 2 * math.pi;
}

class _CosmicPainter extends CustomPainter {
  final double animation;
  final List<_Star> stars;
  final List<Color> colors;
  final Color backgroundColor;

  _CosmicPainter({
    required this.animation,
    required this.stars,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw nebula-like gradient background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(backgroundColor, colors[0], 0.2)!,
            backgroundColor,
            Color.lerp(backgroundColor, colors[1], 0.15)!,
          ],
          center: Alignment(0.3, -0.2),
          radius: 1.5,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw twinkling stars
    for (final star in stars) {
      final twinkle = (math.sin(animation * 4 * math.pi + star.twinkleOffset) + 1) / 2;
      final alpha = 0.4 + twinkle * 0.6;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * twinkle,
        Paint()
          ..color = colors[stars.indexOf(star) % colors.length]
              .withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Neon Tokyo Background (Rain effect)
class NeonTokyoBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const NeonTokyoBackground({super.key, required this.colorScheme});

  @override
  State<NeonTokyoBackground> createState() => _NeonTokyoBackgroundState();
}

class _NeonTokyoBackgroundState extends State<NeonTokyoBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_RainDrop> rainDrops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    rainDrops = List.generate(50, (index) => _RainDrop());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NeonTokyoPainter(
            animation: _controller.value,
            rainDrops: rainDrops,
            colors: [
              widget.colorScheme.primary,
              widget.colorScheme.secondary,
              widget.colorScheme.tertiary,
            ],
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RainDrop {
  final double x;
  final double speed;
  final double length;
  final double width;

  _RainDrop()
      : x = math.Random().nextDouble(),
        speed = math.Random().nextDouble() * 0.5 + 0.5,
        length = math.Random().nextDouble() * 30 + 20,
        width = math.Random().nextDouble() * 1 + 1;
}

class _NeonTokyoPainter extends CustomPainter {
  final double animation;
  final List<_RainDrop> rainDrops;
  final List<Color> colors;
  final Color backgroundColor;

  _NeonTokyoPainter({
    required this.animation,
    required this.rainDrops,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw rain drops - seamless loop
    for (final drop in rainDrops) {
      // Use continuous animation value without modulo for smooth loop
      final rawY = (animation * drop.speed) * (size.height + drop.length);
      // Wrap around when off screen
      final y = rawY % (size.height + drop.length) - drop.length;
      final x = drop.x * size.width;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            colors[rainDrops.indexOf(drop) % colors.length].withValues(alpha: 0.6),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, drop.width, drop.length))
        ..strokeWidth = drop.width
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Ocean Deep Background (Bubbles and waves)
class OceanDeepBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const OceanDeepBackground({super.key, required this.colorScheme});

  @override
  State<OceanDeepBackground> createState() => _OceanDeepBackgroundState();
}

class _OceanDeepBackgroundState extends State<OceanDeepBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Bubble> bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    bubbles = List.generate(30, (index) => _Bubble());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OceanDeepPainter(
            animation: _controller.value,
            bubbles: bubbles,
            colors: [
              widget.colorScheme.primary,
              widget.colorScheme.secondary,
              widget.colorScheme.tertiary,
            ],
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Bubble {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double wobble;

  _Bubble()
      : x = math.Random().nextDouble(),
        startY = math.Random().nextDouble(),
        size = math.Random().nextDouble() * 15 + 5,
        speed = math.Random().nextDouble() * 0.3 + 0.2,
        wobble = math.Random().nextDouble() * 20 + 10;
}

class _OceanDeepPainter extends CustomPainter {
  final double animation;
  final List<_Bubble> bubbles;
  final List<Color> colors;
  final Color backgroundColor;

  _OceanDeepPainter({
    required this.animation,
    required this.bubbles,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Underwater gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(backgroundColor, colors[1], 0.3)!,
            backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw bubbles - seamless loop
    for (final bubble in bubbles) {
      // Calculate continuous progress for seamless loop
      final rawProgress = animation * bubble.speed + bubble.startY;
      final progress = rawProgress % 1.0;

      final y = size.height - (progress * size.height);
      final x = bubble.x * size.width +
                math.sin(rawProgress * 4 * math.pi) * bubble.wobble;

      final alpha = 1.0 - progress * 0.5;

      canvas.drawCircle(
        Offset(x, y),
        bubble.size * (1.0 + progress * 0.5),
        Paint()
          ..color = colors[bubbles.indexOf(bubble) % colors.length]
              .withValues(alpha: alpha * 0.3)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        Offset(x, y),
        bubble.size * (1.0 + progress * 0.5),
        Paint()
          ..color = colors[bubbles.indexOf(bubble) % colors.length]
              .withValues(alpha: alpha * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Sunset Arcade Background (Gradient with floating shapes)
class SunsetArcadeBackground extends StatefulWidget {
  final ColorScheme colorScheme;

  const SunsetArcadeBackground({super.key, required this.colorScheme});

  @override
  State<SunsetArcadeBackground> createState() => _SunsetArcadeBackgroundState();
}

class _SunsetArcadeBackgroundState extends State<SunsetArcadeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SunsetArcadePainter(
            animation: _controller.value,
            colors: [
              widget.colorScheme.primary,
              widget.colorScheme.secondary,
              widget.colorScheme.tertiary,
            ],
            backgroundColor: widget.colorScheme.surface,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _SunsetArcadePainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final Color backgroundColor;

  _SunsetArcadePainter({
    required this.animation,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Animated sunset gradient
    final gradientOffset = math.sin(animation * 2 * math.pi) * 0.2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(colors[0], colors[1], 0.5 + gradientOffset)!,
            Color.lerp(colors[1], colors[2], 0.5)!,
            backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw floating geometric shapes - seamless loop
    final numShapes = 8;
    for (int i = 0; i < numShapes; i++) {
      // Use continuous animation for smoother transitions
      final rawProgress = animation + i / numShapes;
      final progress = rawProgress % 1.0;

      final x = (i / numShapes) * size.width + math.sin(rawProgress * 2 * math.pi) * 50;
      // Wrap y position seamlessly
      final y = (progress * size.height) % (size.height + 100) - 50;
      final rotation = rawProgress * 2 * math.pi;
      final size0 = 30 + i * 5.0;

      // Only draw if visible
      if (y >= -50 && y <= size.height + 50) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        final shapePaint = Paint()
          ..color = colors[i % colors.length].withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        if (i % 2 == 0) {
          // Draw square
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: size0, height: size0),
            shapePaint,
          );
        } else {
          // Draw triangle
          final path = Path();
          path.moveTo(0, -size0 / 2);
          path.lineTo(size0 / 2, size0 / 2);
          path.lineTo(-size0 / 2, size0 / 2);
          path.close();
          canvas.drawPath(path, shapePaint);
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
