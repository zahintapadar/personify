import 'package:flutter/material.dart';

class SimpleGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const SimpleGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [
            const Color(0xFF1a1a1a),
            const Color(0xFF000000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
