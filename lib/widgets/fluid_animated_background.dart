import 'package:flutter/material.dart';
import 'dart:math' as math;

class FluidAnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;
  final bool enableAnimation;

  const FluidAnimatedBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 8),
    this.enableAnimation = true,
  });

  @override
  State<FluidAnimatedBackground> createState() => _FluidAnimatedBackgroundState();
}

class _FluidAnimatedBackgroundState extends State<FluidAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    if (widget.enableAnimation) {
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    // Multiple controllers with different speeds for fluid motion
    _controller1 = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _controller2 = AnimationController(
      duration: Duration(milliseconds: (widget.duration.inMilliseconds * 1.3).round()),
      vsync: this,
    );
    
    _controller3 = AnimationController(
      duration: Duration(milliseconds: (widget.duration.inMilliseconds * 0.8).round()),
      vsync: this,
    );

    _animation1 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.linear,
    ));

    _animation2 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.linear,
    ));

    _animation3 = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.linear,
    ));

    // Start animations
    _controller1.repeat();
    _controller2.repeat();
    _controller3.repeat();
  }

  @override
  void dispose() {
    if (widget.enableAnimation) {
      _controller1.dispose();
      _controller2.dispose();
      _controller3.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return _buildStaticBackground();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_animation1, _animation2, _animation3]),
      builder: (context, child) {
        return CustomPaint(
          painter: FluidBackgroundPainter(
            animation1: _animation1.value,
            animation2: _animation2.value,
            animation3: _animation3.value,
            colors: widget.colors ?? _defaultColors,
          ),
          child: widget.child,
        );
      },
    );
  }

  Widget _buildStaticBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.colors ?? _defaultColors,
        ),
      ),
      child: widget.child,
    );
  }

  List<Color> get _defaultColors => [
    const Color(0xFF6B73FF), // Modern purple-blue
    const Color(0xFF000DFF), // Deep blue
    const Color(0xFF9A0DFF), // Purple
    const Color(0xFFFF6B9D), // Pink
  ];
}

class FluidBackgroundPainter extends CustomPainter {
  final double animation1;
  final double animation2;
  final double animation3;
  final List<Color> colors;

  FluidBackgroundPainter({
    required this.animation1,
    required this.animation2,
    required this.animation3,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create fluid gradient with moving elements
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Animated gradient that moves from one end to the other
    final gradientAnimation = (animation1 + animation2) / 2; // Combine animations for smoother movement
    final moveX = math.sin(gradientAnimation) * 0.8; // Move along X-axis
    final moveY = math.cos(gradientAnimation * 0.7) * 0.6; // Move along Y-axis
    
    final gradient = LinearGradient(
      begin: Alignment(
        -1.0 + moveX, // Start point moves
        -1.0 + moveY,
      ),
      end: Alignment(
        1.0 - moveX, // End point moves in opposite direction
        1.0 - moveY,
      ),
      colors: colors,
      stops: [
        0.0,
        0.3 + 0.1 * math.sin(gradientAnimation * 1.5),
        0.7 + 0.1 * math.cos(gradientAnimation * 1.2),
        1.0,
      ],
    ).createShader(rect);
    
    paint.shader = gradient;
    canvas.drawRect(rect, paint);

    // Add fluid moving shapes for depth (reduced opacity for subtlety)
    _drawFluidShape(canvas, size, paint, animation1, 0.15, colors[0]);
    _drawFluidShape(canvas, size, paint, animation2, 0.1, colors[1]);
    _drawFluidShape(canvas, size, paint, animation3, 0.08, colors[2]);
  }

  void _drawFluidShape(Canvas canvas, Size size, Paint paint, double animation, 
                      double opacity, Color color) {
    final center = Offset(
      size.width * (0.5 + 0.2 * math.sin(animation)),
      size.height * (0.5 + 0.3 * math.cos(animation * 0.8)),
    );

    final radius = size.width * (0.4 + 0.1 * math.sin(animation * 1.5));

    final shapePaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Create organic blob shape
    final path = Path();
    const int points = 8;
    
    for (int i = 0; i < points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final radiusVariation = 1 + 0.3 * math.sin(animation * 2 + angle * 3);
      final currentRadius = radius * radiusVariation;
      
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Add smooth curves between points
        final prevAngle = ((i - 1) / points) * 2 * math.pi;
        final prevRadiusVar = 1 + 0.3 * math.sin(animation * 2 + prevAngle * 3);
        final prevRadius = radius * prevRadiusVar;
        
        final prevX = center.dx + prevRadius * math.cos(prevAngle);
        final prevY = center.dy + prevRadius * math.sin(prevAngle);
        
        final controlX = (prevX + x) / 2 + 20 * math.sin(animation + angle);
        final controlY = (prevY + y) / 2 + 20 * math.cos(animation + angle);
        
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, shapePaint);
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.animation1 != animation1 ||
           oldDelegate.animation2 != animation2 ||
           oldDelegate.animation3 != animation3;
  }
}

// Optimized version for lower-end devices
class SimpleFluidBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const SimpleFluidBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<SimpleFluidBackground> createState() => _SimpleFluidBackgroundState();
}

class _SimpleFluidBackgroundState extends State<SimpleFluidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
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
        // Create sweeping gradient motion from left to right
        final sweepProgress = _animation.value;
        final moveX = math.sin(sweepProgress * 2 * math.pi) * 0.8; // Increased movement
        final moveY = math.cos(sweepProgress * 2 * math.pi * 0.8) * 0.6;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1.0 + moveX,
                -1.0 + moveY,
              ),
              end: Alignment(
                1.0 - moveX,
                1.0 - moveY,
              ),
              colors: widget.colors ?? [
                const Color(0xFF6B73FF),
                const Color(0xFF000DFF),
                const Color(0xFF9A0DFF),
                const Color(0xFFFF6B9D),
              ],
              stops: [
                0.0,
                0.25 + 0.1 * math.sin(sweepProgress * 2 * math.pi * 1.3),
                0.75 + 0.1 * math.cos(sweepProgress * 2 * math.pi * 1.1),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
