import 'package:flutter/material.dart';

class GlowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final double blurRadius;

  const GlowText(
    this.text, {
    super.key,
    required this.style,
    required this.glowColor,
    this.blurRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        shadows: [
          Shadow(color: glowColor.withOpacity(0.9), blurRadius: blurRadius),
          Shadow(color: glowColor.withOpacity(0.4), blurRadius: blurRadius * 2),
        ],
      ),
    );
  }
}
