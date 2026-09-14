import 'package:flutter/material.dart';
import 'fade_animations.dart';

/// Wraps [child] and plays a subtle fade, scale, and lift when it enters view.
class ScrollAnimate extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideBegin;
  final double visibleFraction;

  const ScrollAnimate({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 760),
    this.slideBegin = 0.035,
    this.visibleFraction = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothFade(
      key: key,
      duration: duration,
      delay: delay,
      slideBegin: slideBegin,
      visibleFraction: visibleFraction,
      child: child,
    );
  }
}
