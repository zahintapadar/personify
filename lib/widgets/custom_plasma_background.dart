import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math' as math;
import 'dart:ui';

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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Base gradient with your specified colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.mirror,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffff1100),
                  Color(0xff2129f3),
                  Color(0xfffb0004),
                ],
                stops: [
                  0,
                  0.5,
                  1,
                ],
              ),
              backgroundBlendMode: BlendMode.srcOver,
            ),
          ),
          
          // Animated plasma-like orbs (particles)
          ...List.generate(10, (index) => _buildPlasmaOrb(index)),
          
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildPlasmaOrb(int index) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      duration: Duration(seconds: (animationDuration.inSeconds * 2.92).round() + index),
      builder: (context, value, _) {
        final size = 0.96 * (100 + index * 20);
        final speed = 2.92;
        final x = math.sin(value * speed + index * 0.7) * 0.3;
        final y = math.cos(value * speed * 1.3 + index * 0.5) * 0.4;
        
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x) - size / 2,
          top: MediaQuery.of(context).size.height * (0.5 + y) - size / 2,
          child: Transform.scale(
            scale: 0.8 + math.sin(value * 2 + index) * 0.2,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x44e45a23).withOpacity(0.4),
                    Color(0x44e45a23).withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.4 * 10, sigmaY: 0.4 * 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0x44e45a23).withOpacity(0.1),
                      shape: BoxShape.circle,
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

class CustomPlasmaRenderer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;

  const CustomPlasmaRenderer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 10),
    this.particles = 10,
    this.color = const Color(0x44e45a23),
    this.blur = 0.4,
    this.size = 0.96,
    this.speed = 2.92,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          tileMode: TileMode.mirror,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffff1100),
            Color(0xff2129f3),
            Color(0xfffb0004),
          ],
          stops: [
            0,
            0.5,
            1,
          ],
        ),
        backgroundBlendMode: BlendMode.srcOver,
      ),
      child: Stack(
        children: [
          // Animated plasma effect simulation
          ...List.generate(particles, (index) => _buildParticle(index, context)),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildParticle(int particleIndex, BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      duration: Duration(seconds: (duration.inSeconds * speed).round() + particleIndex),
      builder: (context, value, _) {
        final particleSize = size * (50 + particleIndex * 10);
        final x = math.sin(value * speed + particleIndex * 0.7) * 0.3;
        final y = math.cos(value * speed * 1.3 + particleIndex * 0.5) * 0.4;
        
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x) - particleSize / 2,
          top: MediaQuery.of(context).size.height * (0.5 + y) - particleSize / 2,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur * 10, sigmaY: blur * 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    backgroundBlendMode: BlendMode.plus,
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
                  const Color(0xffff1100),
                  const Color(0xff2129f3),
                  math.sin(value * math.pi),
                )!,
                Color.lerp(
                  const Color(0xff2129f3),
                  const Color(0xfffb0004),
                  math.cos(value * math.pi),
                )!,
                Color.lerp(
                  const Color(0xfffb0004),
                  const Color(0xffff1100),
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
