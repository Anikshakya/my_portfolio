import 'dart:math';
import 'package:flutter/material.dart';

class StarData {
  double x, y, r, opacity, speed;
  StarData(this.x, this.y, this.r, this.opacity, this.speed);
}

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StarData> _stars;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _stars = List.generate(180, (_) => StarData(
      _rand.nextDouble(),
      _rand.nextDouble(),
      _rand.nextDouble() * 1.8 + 0.3,
      _rand.nextDouble() * 0.7 + 0.3,
      _rand.nextDouble() * 0.3 + 0.1,
    ));
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _controller.addListener(() => setState(() {
      for (final star in _stars) {
        star.opacity = 0.3 + 0.7 * (0.5 + 0.5 * sin(_controller.value * 2 * pi * star.speed + star.x * 10));
      }
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(_stars),
      child: const SizedBox.expand(),
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<StarData> stars;
  _StarPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF020208));
    for (final star in stars) {
      final paint = Paint()..color = Colors.white.withOpacity(star.opacity * 0.85);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}
