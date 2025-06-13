import 'package:flutter/material.dart';
import 'fluid_animated_background.dart';
import '../services/app_preferences.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final bool? forceAnimation; // Override preferences if specified

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.forceAnimation,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  bool _animationEnabled = true;
  bool _simpleMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (widget.forceAnimation != null) {
      setState(() {
        _animationEnabled = widget.forceAnimation!;
        _isLoading = false;
      });
      return;
    }

    try {
      final animationEnabled = await AppPreferences.getBackgroundAnimationEnabled();
      final simpleMode = await AppPreferences.getSimpleAnimationMode();
      
      if (mounted) {
        setState(() {
          _animationEnabled = animationEnabled;
          _simpleMode = simpleMode;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to default values
      if (mounted) {
        setState(() {
          _animationEnabled = true;
          _simpleMode = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildStaticBackground(); // Show static background while loading
    }

    if (!_animationEnabled) {
      return _buildStaticBackground();
    }

    // Use simple animation for better performance when enabled
    if (_simpleMode) {
      return SimpleFluidBackground(
        colors: widget.colors,
        child: widget.child,
      );
    }

    // Use full fluid animation
    return FluidAnimatedBackground(
      colors: widget.colors,
      enableAnimation: _animationEnabled,
      child: widget.child,
    );
  }

  Widget _buildStaticBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.colors ?? [
            const Color(0xFF6B73FF), // Modern purple-blue
            const Color(0xFF000DFF), // Deep blue
            const Color(0xFF9A0DFF), // Purple
            const Color(0xFFFF6B9D), // Pink
          ],
        ),
      ),
      child: widget.child,
    );
  }
}
