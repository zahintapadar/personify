import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPersonalityText extends StatelessWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration speed;
  final bool repeatForever;
  final Color? highlightColor;

  const AnimatedPersonalityText({
    super.key,
    required this.texts,
    this.textStyle,
    this.speed = const Duration(milliseconds: 100),
    this.repeatForever = true,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: texts.map((text) => TypewriterAnimatedText(
        text,
        textStyle: textStyle ?? GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        speed: speed,
      )).toList(),
      isRepeatingAnimation: repeatForever,
      pause: const Duration(milliseconds: 2000),
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }
}

class FadeInAnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration duration;

  const FadeInAnimatedText({
    super.key,
    required this.text,
    this.textStyle,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        FadeAnimatedText(
          text,
          textStyle: textStyle ?? GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white.withOpacity(0.9),
          ),
          duration: duration,
        ),
      ],
      isRepeatingAnimation: false,
    );
  }
}

class ScalingAnimatedText extends StatelessWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration duration;

  const ScalingAnimatedText({
    super.key,
    required this.texts,
    this.textStyle,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: texts.map((text) => ScaleAnimatedText(
        text,
        textStyle: textStyle ?? GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        duration: duration,
      )).toList(),
      isRepeatingAnimation: true,
      pause: const Duration(milliseconds: 1000),
    );
  }
}

class WavyAnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration speed;

  const WavyAnimatedText({
    super.key,
    required this.text,
    this.textStyle,
    this.speed = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText(
          text,
          textStyle: textStyle ?? GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          speed: speed,
        ),
      ],
      isRepeatingAnimation: false,
    );
  }
}

class ColorizeAnimatedText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? textStyle;
  final Duration speed;

  const ColorizeAnimatedText({
    super.key,
    required this.text,
    required this.colors,
    this.textStyle,
    this.speed = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        ColorizeAnimatedText(
          text,
          textStyle: textStyle ?? GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          colors: colors,
          speed: speed,
        ),
      ],
      isRepeatingAnimation: true,
      pause: const Duration(milliseconds: 1000),
    );
  }
}
