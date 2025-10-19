import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// A beautiful particle background with colorful flowing particles
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    )..repeat();

    // Create 50 particles for better performance
    particles = List.generate(50, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate continuous time in seconds (never resets)
        final elapsedSeconds = DateTime.now().difference(startTime).inMilliseconds / 1000.0;

        return CustomPaint(
          painter: ParticlePainter(
            time: elapsedSeconds,
            particles: particles,
            backgroundColor: theme.colorScheme.surface,
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
            tertiaryColor: theme.colorScheme.tertiary,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class Particle {
  final double startX;
  final double startY;
  final double size;
  final double speedX;
  final double speedY;
  final double wobbleSpeed;
  final double wobbleAmount;
  final int colorIndex;
  final double pulseOffset;

  Particle()
      : startX = math.Random().nextDouble(),
        startY = math.Random().nextDouble(),
        size = math.Random().nextDouble() * 5 + 3,
        speedX = (math.Random().nextDouble() - 0.5) * 0.03,
        speedY = (math.Random().nextDouble() - 0.5) * 0.03,
        wobbleSpeed = math.Random().nextDouble() * 0.4 + 0.2,
        wobbleAmount = math.Random().nextDouble() * 20 + 10,
        colorIndex = math.Random().nextInt(3),
        pulseOffset = math.Random().nextDouble() * math.pi * 2;
}

class ParticlePainter extends CustomPainter {
  final double time;
  final List<Particle> particles;
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  ParticlePainter({
    required this.time,
    required this.particles,
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.65, size.height * 0.3),
        size.width * 0.6,
        [
          Color.lerp(backgroundColor, primaryColor, 0.12)!,
          backgroundColor,
          Color.lerp(backgroundColor, secondaryColor, 0.08)!,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(rect, gradientPaint);

    // Pre-calculate color array for faster lookup
    final colors = [primaryColor, secondaryColor, tertiaryColor];

    // Pre-calculate time-based values (continuous, never resets)
    final timePi2 = time * 2 * math.pi;
    final timePi3 = time * 3 * math.pi;

    // Draw particles in single loop
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];

      // Calculate position with continuous movement (never jumps)
      final baseX = particle.startX + (time * particle.speedX);
      final baseY = particle.startY + (time * particle.speedY);

      // Add wobble effect
      final wobblePhase = timePi2 * particle.wobbleSpeed;
      final wobbleX = math.sin(wobblePhase) * particle.wobbleAmount;
      final wobbleY = math.cos(wobblePhase) * particle.wobbleAmount;

      // Wrap around screen edges smoothly
      final wrappedX = (baseX % 1.0 + 1.0) % 1.0;
      final wrappedY = (baseY % 1.0 + 1.0) % 1.0;

      final x = wrappedX * size.width + wobbleX;
      final y = wrappedY * size.height + wobbleY;

      // Get color from pre-calculated array
      final particleColor = colors[particle.colorIndex];

      // Calculate pulse (optimized)
      final pulse = (math.sin(timePi3 + particle.pulseOffset) + 1) * 0.5;
      final alpha = 0.4 + pulse * 0.3;

      final offset = Offset(x, y);

      // Draw outer glow (single layer, optimized blur)
      canvas.drawCircle(
        offset,
        particle.size * 2,
        Paint()
          ..color = particleColor.withValues(alpha: alpha * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Draw main particle with gradient
      canvas.drawCircle(
        offset,
        particle.size,
        Paint()
          ..shader = ui.Gradient.radial(
            offset,
            particle.size,
            [
              particleColor.withValues(alpha: alpha),
              particleColor.withValues(alpha: alpha * 0.6),
            ],
          ),
      );
    }

    // Draw fewer connecting lines with optimized distance check
    final maxConnections = 3; // Limit connections per particle
    for (int i = 0; i < particles.length; i++) {
      int connections = 0;
      final p1 = particles[i];

      // Calculate p1 position
      final baseX1 = p1.startX + (time * p1.speedX);
      final baseY1 = p1.startY + (time * p1.speedY);
      final wobblePhase1 = timePi2 * p1.wobbleSpeed;
      final wrappedX1 = (baseX1 % 1.0 + 1.0) % 1.0;
      final wrappedY1 = (baseY1 % 1.0 + 1.0) % 1.0;
      final x1 = wrappedX1 * size.width + math.sin(wobblePhase1) * p1.wobbleAmount;
      final y1 = wrappedY1 * size.height + math.cos(wobblePhase1) * p1.wobbleAmount;

      for (int j = i + 1; j < particles.length && connections < maxConnections; j++) {
        final p2 = particles[j];

        // Calculate p2 position
        final baseX2 = p2.startX + (time * p2.speedX);
        final baseY2 = p2.startY + (time * p2.speedY);
        final wobblePhase2 = timePi2 * p2.wobbleSpeed;
        final wrappedX2 = (baseX2 % 1.0 + 1.0) % 1.0;
        final wrappedY2 = (baseY2 % 1.0 + 1.0) % 1.0;
        final x2 = wrappedX2 * size.width + math.sin(wobblePhase2) * p2.wobbleAmount;
        final y2 = wrappedY2 * size.height + math.cos(wobblePhase2) * p2.wobbleAmount;

        final dx = x2 - x1;
        final dy = y2 - y1;
        final distanceSquared = dx * dx + dy * dy;

        // Use squared distance to avoid expensive sqrt
        if (distanceSquared < 10000) { // 100^2
          final distance = math.sqrt(distanceSquared);
          final alpha = (1 - distance / 100) * 0.12;

          canvas.drawLine(
            Offset(x1, y1),
            Offset(x2, y2),
            Paint()
              ..color = primaryColor.withValues(alpha: alpha)
              ..strokeWidth = 0.8,
          );
          connections++;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
