import 'package:flutter/material.dart';

class AnimationUtils {
  // Slide in from bottom animation
  static Widget slideInFromBottom(Widget child, {Duration duration = const Duration(milliseconds: 600)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 50),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Scale fade in animation
  static Widget scaleFadeIn(Widget child, {Duration duration = const Duration(milliseconds: 400)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Slide in from left animation
  static Widget slideInFromLeft(Widget child, {Duration duration = const Duration(milliseconds: 500)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-100 * value, 0),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Slide in from right animation
  static Widget slideInFromRight(Widget child, {Duration duration = const Duration(milliseconds: 500)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(100 * value, 0),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Bounce in animation
  static Widget bounceIn(Widget child, {Duration duration = const Duration(milliseconds: 800)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredListItem(Widget child, int index, {Duration delay = const Duration(milliseconds: 100)}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 30),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Pulse animation
  static Widget pulse(Widget child, {Duration duration = const Duration(milliseconds: 1500)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        double scale = 1.0 + (0.1 * (0.5 + 0.5 * value));
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }

  // Shimmer loading animation
  static Widget shimmer(Widget child, {Duration duration = const Duration(milliseconds: 1500)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: -1.0, end: 1.0),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // Floating animation
  static Widget floating(Widget child, {Duration duration = const Duration(milliseconds: 2000)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: 6.28), // 2π for full circle
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 5 * (0.5 + 0.5 * (value * 0.5).sin())),
          child: child,
        );
      },
      child: child,
    );
  }

  // Card flip animation
  static Widget cardFlip(Widget frontChild, Widget backChild, bool showFront, {Duration duration = const Duration(milliseconds: 600)}) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: showFront ? 0.0 : 1.0, end: showFront ? 0.0 : 1.0),
      builder: (context, value, child) {
        if (value < 0.5) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 3.14159),
            child: frontChild,
          );
        } else {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((1 - value) * 3.14159),
            child: backChild,
          );
        }
      },
    );
  }
}

// Enhanced animated button widget
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 200),
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

// Enhanced animated container
class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(milliseconds: 3000),
    this.borderRadius,
    this.padding,
  });

  @override
  State<AnimatedGradientContainer> createState() => _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
            borderRadius: widget.borderRadius,
          ),
          padding: widget.padding,
          child: widget.child,
        );
      },
    );
  }
}
