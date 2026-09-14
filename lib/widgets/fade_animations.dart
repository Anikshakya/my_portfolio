import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Shared entrance animation for the portfolio screens.
///
/// Tuned with an Apple-style cinematic feel: longer duration, deeper spatial 
/// scaling, and an ultra-smooth custom ease-out curve.
class SmoothFade extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double slideBegin;
  final double scaleBegin;
  final double visibleFraction;

  const SmoothFade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1050), // Slower, heavier, more cinematic
    this.delay = Duration.zero,
    this.slideBegin = 40.0, // Pixel-based offset for physical weight
    this.scaleBegin = 0.94, // Deeper scale for a true "coming forward" depth
    this.visibleFraction = 0.15,
  });

  @override
  State<SmoothFade> createState() => _SmoothFadeState();
}

class _SmoothFadeState extends State<SmoothFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _started = false;

  // Apple's signature smooth-out curve approximation: 
  // Fast initial motion that decelerates into an extremely gentle finish.
  static const Cubic _appleEaseOut = Cubic(0.16, 1.0, 0.3, 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Staggered opacity: fades in quicker than structural movement completes,
    // mirroring Apple's technique of revealing content early while it settles.
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: _appleEaseOut),
      ),
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideBegin),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _appleEaseOut,
      ),
    );

    _scale = Tween<double>(
      begin: widget.scaleBegin,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: _appleEaseOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    _started = true;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? ValueKey(widget.hashCode),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= widget.visibleFraction) {
          _start();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          return FadeTransition(
            opacity: _opacity,
            child: Transform.translate(
              // Using pixel-based translation for a crisp, high-end feel
              offset: Offset(0, _slide.value.dy),
              child: ScaleTransition(
                scale: _scale,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}