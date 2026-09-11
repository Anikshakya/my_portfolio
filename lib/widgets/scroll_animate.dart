import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps [child] and plays a subtle fade, scale, and lift when it enters view.
class ScrollAnimate extends StatefulWidget {
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
  State<ScrollAnimate> createState() => _ScrollAnimateState();
}

class _ScrollAnimateState extends State<ScrollAnimate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideBegin),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_triggered && info.visibleFraction >= widget.visibleFraction) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? ValueKey(widget.hashCode),
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topCenter,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
