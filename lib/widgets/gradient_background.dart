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
          tileMode: TileMode.mirror,
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xfff44336), // Red
            const Color(0xff2196f3), // Blue
          ],
        ),
      ),
      child: child,
    );
  }
}
