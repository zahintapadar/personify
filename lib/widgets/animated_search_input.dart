import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class AnimatedSearchInput extends StatefulWidget {
  final String placeholder;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;

  const AnimatedSearchInput({
    super.key,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  State<AnimatedSearchInput> createState() => _AnimatedSearchInputState();
}

class _AnimatedSearchInputState extends State<AnimatedSearchInput>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _hoverController;
  late FocusNode _focusNode;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _hoverController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: Container(
        width: 314,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background grid effect
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
            
            // Glow effect
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Container(
                  width: 354,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: GlowPainter(
                      rotation: _rotationController.value * 2 * math.pi + (60 * math.pi / 180),
                      isHovered: _isHovered,
                      isFocused: _isFocused,
                    ),
                  ),
                );
              },
            ),
            
            // Dark border backgrounds
            ...List.generate(3, (index) => 
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Container(
                    width: 312,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: DarkBorderPainter(
                        rotation: _rotationController.value * 2 * math.pi + (82 * math.pi / 180),
                        isHovered: _isHovered,
                        isFocused: _isFocused,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // White border
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Container(
                  width: 307,
                  height: 63,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: WhiteBorderPainter(
                      rotation: _rotationController.value * 2 * math.pi + (83 * math.pi / 180),
                      isHovered: _isHovered,
                      isFocused: _isFocused,
                    ),
                  ),
                );
              },
            ),
            
            // Main border
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Container(
                  width: 303,
                  height: 59,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: CustomPaint(
                    painter: MainBorderPainter(
                      rotation: _rotationController.value * 2 * math.pi + (70 * math.pi / 180),
                      isHovered: _isHovered,
                      isFocused: _isFocused,
                    ),
                  ),
                );
              },
            ),
            
            // Main input container
            Container(
              width: 301,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF010201),
              ),
              child: Stack(
                children: [
                  // Pink mask effect
                  if (!_isFocused)
                    AnimatedBuilder(
                      animation: _hoverController,
                      builder: (context, child) {
                        return Positioned(
                          top: 10,
                          left: 5,
                          child: AnimatedOpacity(
                            opacity: _isHovered ? 0.0 : 0.8,
                            duration: const Duration(milliseconds: 2000),
                            child: Container(
                              width: 30,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCF30AA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Input field
                  Positioned.fill(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: const TextStyle(
                          color: Color(0xFFC0B9C0),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 59, right: 59, top: 18),
                      ),
                    ),
                  ),
                  
                  // Input mask (gradient effect)
                  if (!_isFocused)
                    Positioned(
                      top: 18,
                      left: 70,
                      child: Container(
                        width: 100,
                        height: 20,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ),
                  
                  // Search icon
                  Positioned(
                    left: 20,
                    top: 15,
                    child: CustomPaint(
                      size: const Size(24, 24),
                      painter: SearchIconPainter(),
                    ),
                  ),
                  
                  // Filter icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 38,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF161329),
                            Colors.black,
                            Color(0xFF1D1B4B),
                          ],
                        ),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Stack(
                        children: [
                          // Filter border effect
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomPaint(
                                painter: FilterBorderPainter(
                                  rotation: _rotationController.value * 2 * math.pi,
                                ),
                              ),
                            ),
                          ),
                          // Filter icon
                          Center(
                            child: CustomPaint(
                              size: const Size(27, 27),
                              painter: FilterIconPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painters for different effects
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F0F10).withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSize = 16.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlowPainter extends CustomPainter {
  final double rotation;
  final bool isHovered;
  final bool isFocused;

  GlowPainter({required this.rotation, required this.isHovered, required this.isFocused});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.7;
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: rotation,
        endAngle: rotation + 2 * math.pi,
        colors: [
          Colors.black,
          const Color(0xFF402FB5).withOpacity(0.5),
          Colors.black,
          Colors.black,
          const Color(0xFFCF30AA).withOpacity(0.5),
          Colors.black,
        ],
        stops: const [0.0, 0.05, 0.38, 0.5, 0.6, 0.87],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DarkBorderPainter extends CustomPainter {
  final double rotation;
  final bool isHovered;
  final bool isFocused;

  DarkBorderPainter({required this.rotation, required this.isHovered, required this.isFocused});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.7;
    
    double actualRotation = rotation;
    if (isHovered) {
      actualRotation = rotation - math.pi * 0.54; // -98 degrees
    }
    if (isFocused) {
      actualRotation = rotation + math.pi * 2.45; // 442 degrees
    }
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: actualRotation,
        endAngle: actualRotation + 2 * math.pi,
        colors: [
          Colors.transparent,
          const Color(0xFF18116A),
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF6E1B60),
          Colors.transparent,
        ],
        stops: const [0.0, 0.1, 0.1, 0.5, 0.6, 0.6],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WhiteBorderPainter extends CustomPainter {
  final double rotation;
  final bool isHovered;
  final bool isFocused;

  WhiteBorderPainter({required this.rotation, required this.isHovered, required this.isFocused});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.7;
    
    double actualRotation = rotation;
    if (isHovered) {
      actualRotation = rotation - math.pi * 0.54; // -97 degrees
    }
    if (isFocused) {
      actualRotation = rotation + math.pi * 2.46; // 443 degrees
    }
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: actualRotation,
        endAngle: actualRotation + 2 * math.pi,
        colors: [
          Colors.transparent,
          const Color(0xFFA099D8),
          Colors.transparent,
          Colors.transparent,
          const Color(0xFFDFA2DA),
          Colors.transparent,
        ],
        stops: const [0.0, 0.08, 0.08, 0.5, 0.58, 0.58],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MainBorderPainter extends CustomPainter {
  final double rotation;
  final bool isHovered;
  final bool isFocused;

  MainBorderPainter({required this.rotation, required this.isHovered, required this.isFocused});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.7;
    
    double actualRotation = rotation;
    if (isHovered) {
      actualRotation = rotation - math.pi * 0.61; // -110 degrees
    }
    if (isFocused) {
      actualRotation = rotation + math.pi * 2.39; // 430 degrees
    }
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: actualRotation,
        endAngle: actualRotation + 2 * math.pi,
        colors: [
          const Color(0xFF1C191C),
          const Color(0xFF402FB5),
          const Color(0xFF1C191C),
          const Color(0xFF1C191C),
          const Color(0xFFCF30AA),
          const Color(0xFF1C191C),
        ],
        stops: const [0.0, 0.05, 0.14, 0.5, 0.6, 0.64],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SearchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Circle
    paint.shader = const LinearGradient(
      colors: [Color(0xFFF8E7F8), Color(0xFFB6A9B7)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawCircle(const Offset(11, 11), 8, paint);

    // Line
    paint.shader = const LinearGradient(
      colors: [Color(0xFFB6A9B7), Color(0xFF837484)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawLine(const Offset(16.65, 16.65), const Offset(22, 22), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FilterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6D6E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(8.16, 6.65);
    path.lineTo(15.83, 6.65);
    path.lineTo(13.91, 12.64);
    path.lineTo(13.33, 13.98);
    path.lineTo(13.33, 16.48);
    path.lineTo(12.81, 17.47);
    path.lineTo(12, 17.98);
    path.lineTo(10.2, 16.99);
    path.lineTo(10.2, 13.91);
    path.lineTo(7.52, 10.36);
    path.lineTo(7, 9.20);
    path.lineTo(7, 7.87);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FilterBorderPainter extends CustomPainter {
  final double rotation;

  FilterBorderPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 2;
    
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: rotation,
        endAngle: rotation + 2 * math.pi,
        colors: [
          Colors.transparent,
          const Color(0xFF3D3A4F),
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF3D3A4F),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.5, 0.5, 1.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
