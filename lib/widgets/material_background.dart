import 'package:flutter/material.dart';

class MaterialBackground extends StatelessWidget {
  final Widget child;

  const MaterialBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.04, 0.0),
          radius: 1.2,
          colors: [
            Color(0xFF000000),
            Color(0xFF5829A9),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}