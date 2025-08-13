import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

class ParticleBackground extends StatefulWidget {
  final List<Color> particleColors;
  final int numberOfParticles;

  const ParticleBackground({
    super.key,
    this.particleColors = const [
      Color(0xFF00BCD4), // Cyan
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFFEB3B), // Yellow
      Color(0xFFF44336), // Red
      Color(0xFF9C27B0), // Purple
    ],
    this.numberOfParticles = 50,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _controller.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    _particles = List.generate(widget.numberOfParticles, (index) {
      return Particle(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 2,
          (_random.nextDouble() - 0.5) * 2,
        ),
        size: _random.nextDouble() * 4 + 1,
        color: widget.particleColors[
            _random.nextInt(widget.particleColors.length)],
      );
    });
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    if (_particles.isEmpty) {
      _initializeParticles(size);
    }

    setState(() {
      for (final particle in _particles) {
        particle.position = Offset(
          particle.position.dx + particle.velocity.dx,
          particle.position.dy + particle.velocity.dy,
        );

        // Bounce off edges
        if (particle.position.dx <= 0 || particle.position.dx >= size.width) {
          particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
        }
        if (particle.position.dy <= 0 || particle.position.dy >= size.height) {
          particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: CustomPaint(
        painter: _ParticlePainter(_particles),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      paint.color = particle.color.withValues(alpha: 0.7);
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}