import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xFF421DA9), // 66, 29, 169
            const Color(0xFFFF5934), // 255, 89, 52
            const Color(0xFF421DA9), // 66, 29, 169
          ],
        ),
      ),
      child: child,
    );
  }
}
