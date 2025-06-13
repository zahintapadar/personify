import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math' as math;
import 'dart:ui';

enum PlasmaType {
  infinity,
  bubbles,
  infinity2,
  infinity3,
}

enum ParticleType {
  atlas,
  circle,
}

class PlasmaRenderer extends StatelessWidget {
  final PlasmaType type;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double offset;
  final BlendMode blendMode;
  final ParticleType particleType;
  final double variation1;
  final double variation2;
  final double variation3;
  final double rotation;

  const PlasmaRenderer({
    super.key,
    required this.type,
    required this.particles,
    required this.color,
    required this.blur,
    required this.size,
    required this.speed,
    required this.offset,
    required this.blendMode,
    required this.particleType,
    required this.variation1,
    required this.variation2,
    required this.variation3,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(particles, (index) => _buildParticle(index)),
    );
  }

  Widget _buildParticle(int index) {
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      duration: Duration(seconds: (10 / speed).round() + index),
      curve: Curves.linear,
      builder: (context, value, child) {
        final particleSize = size * (50 + index * 15);
        
        double x, y;
        switch (type) {
          case PlasmaType.infinity:
            final t = value + index * 0.5 + offset;
            x = math.sin(t * speed) * 0.3 + math.sin(t * speed * 2) * 0.1;
            y = math.cos(t * speed) * 0.2 + math.sin(t * speed * 3) * 0.05;
            break;
          case PlasmaType.bubbles:
            x = math.sin(value * speed + index * 1.2) * 0.4;
            y = math.cos(value * speed * 0.8 + index * 0.9) * 0.4;
            break;
          case PlasmaType.infinity2:
            final t = value + index * 0.7 + offset;
            x = math.sin(t * speed * 2) * math.cos(t * speed) * 0.3;
            y = math.sin(t * speed * 3) * 0.2;
            break;
          case PlasmaType.infinity3:
            final t = value + index * 0.3 + offset;
            x = math.sin(t * speed) * 0.3;
            y = math.sin(t * speed * 2) * math.cos(t * speed) * 0.3;
            break;
        }

        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x + variation1 * 0.1) - particleSize / 2,
          top: MediaQuery.of(context).size.height * (0.5 + y + variation2 * 0.1) - particleSize / 2,
          child: Transform.rotate(
            angle: rotation + value * speed,
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                shape: particleType == ParticleType.circle ? BoxShape.circle : BoxShape.rectangle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.6),
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur * 20, sigmaY: blur * 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: particleType == ParticleType.circle ? BoxShape.circle : BoxShape.rectangle,
                      backgroundBlendMode: blendMode,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
