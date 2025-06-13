import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:plasma/plasma.dart';
import 'dart:math' as math;

class PlasmaGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? customColors;
  final Duration animationDuration;

  const PlasmaGradientBackground({
    super.key,
    required this.child,
    this.customColors,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  Widget build(BuildContext context) {
    final colors = customColors ?? [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf093fb),
      const Color(0xFFf5576c),
      const Color(0xFF4facfe),
      const Color(0xFF00f2fe),
    ];

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Base gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[0],
                  colors[1],
                ],
              ),
            ),
          ),
          
          // Animated plasma layers
          ...List.generate(3, (index) => _buildPlasmaLayer(colors, index)),
          
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildPlasmaLayer(List<Color> colors, int layerIndex) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      duration: Duration(seconds: animationDuration.inSeconds + layerIndex * 2),
      builder: (context, value, _) {
        return Positioned.fill(
          child: Transform.rotate(
            angle: value + layerIndex * math.pi / 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    math.sin(value + layerIndex) * 0.5,
                    math.cos(value + layerIndex) * 0.3,
                  ),
                  radius: 1.5 + math.sin(value * 0.5) * 0.3,
                  colors: [
                    colors[(layerIndex + 2) % colors.length].withOpacity(0.3),
                    colors[(layerIndex + 3) % colors.length].withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedPlasmaGradient extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedPlasmaGradient({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 10),
  });

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(value * 2 * math.pi),
              colors: [
                Color.lerp(
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  math.sin(value * math.pi),
                )!,
                Color.lerp(
                  const Color(0xFFf093fb),
                  const Color(0xFFf5576c),
                  math.cos(value * math.pi),
                )!,
                Color.lerp(
                  const Color(0xFF4facfe),
                  const Color(0xFF00f2fe),
                  math.sin(value * math.pi * 2),
                )!,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class PulsingGradientOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final Duration duration;
  final Alignment alignment;

  const PulsingGradientOrb({
    super.key,
    this.size = 200,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: duration,
      builder: (context, value, _) {
        return Align(
          alignment: alignment,
          child: Container(
            width: size * value,
            height: size * value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors.map((c) => c.withOpacity(0.3 / value)).toList(),
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
