import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

class ParticleBackground extends StatelessWidget {
  const ParticleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircularParticle(
      key: UniqueKey(),
      awayRadius: 120,
      numberOfParticles: 150,
      speedOfParticles: 1,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      onTapAnimation: false,
      particleColor: theme.colorScheme.primary.withAlpha(100),
      awayAnimationDuration: const Duration(milliseconds: 400),
      maxParticleSize: 2,
      isRandomColor: false,
      awayAnimationCurve: Curves.fastOutSlowIn,
      enableHover: false,
      connectDots: false,
    );
  }
}