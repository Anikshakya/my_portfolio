import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  late List<Star> stars;
  final Random random = Random();
  double time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    particles = [];
    stars = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (particles.isEmpty) {
      _initializeParticles();
    }
    if (stars.isEmpty) {
      _initializeStars();
    }
  }

  void _initializeParticles() {
    particles.clear();
    for (int i = 0; i < 70; i++) {
      particles.add(Particle(random));
    }
  }

  void _initializeStars() {
    stars.clear();
    for (int i = 0; i < 150; i++) {
      stars.add(Star(random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => IgnorePointer(
        ignoring: true,
        child: CustomPaint(
          painter: _BackgroundPainter(
            particles,
            stars,
            _controller.value * 60,
            HudColors.primary,
            isDarkMode,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class Particle {
  final Random random;
  double x, y, size, speed, angle;
  double opacity;
  double baseSize;
  double twinkleOffset;

  Particle(this.random)
      : x = random.nextDouble(),
        y = random.nextDouble(),
        baseSize = random.nextDouble() * 2 + 2,
        size = 0,
        speed = random.nextDouble() * 0.15 + 0.03,
        angle = random.nextDouble() * 2 * pi,
        opacity = random.nextDouble() * 0.5 + 0.3,
        twinkleOffset = random.nextDouble() * 2 * pi;

  void update(double time) {
    size = baseSize * (1 + sin(time * speed * 3 + twinkleOffset) * 0.3);
    opacity = 0.5 + 0.5 * sin(time * speed * 4 + twinkleOffset);

    x += cos(angle) * speed * 0.0015;
    y += sin(angle) * speed * 0.0015;

    if (x < 0 || x > 1) angle = pi - angle;
    if (y < 0 || y > 1) angle = -angle;
  }
}

class Star {
  final Random random;
  double x, y, size, baseOpacity, twinkleOffset;

  Star(this.random)
      : x = random.nextDouble(),
        y = random.nextDouble(),
        size = random.nextDouble() * 1.2 + 0.3,
        baseOpacity = random.nextDouble() * 0.3 + 0.1,
        twinkleOffset = random.nextDouble() * 2 * pi;

  double getOpacity(double time) {
    return baseOpacity + 0.5 * sin(time * 2 + twinkleOffset);
  }
}

class _BackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final List<Star> stars;
  final double time;
  final Color baseColor;
  final bool isDarkMode;

  late final Paint particlePaint;
  late final Paint linePaint;
  late final Paint starPaint;

  _BackgroundPainter(
    this.particles,
    this.stars,
    this.time,
    this.baseColor,
    this.isDarkMode,
  ) {
    particlePaint = Paint();
    linePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    starPaint = Paint();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Background - simpler for light mode
    final backgroundPaint = Paint()
      ..color = isDarkMode ? HudColors.background : HudColors.lightBackground;
    canvas.drawRect(rect, backgroundPaint);

    // Draw stars - black in light mode, white in dark mode
    for (final star in stars) {
      final starOpacity = star.getOpacity(time).clamp(0, 1);
      starPaint.color = HudColors.primary.withOpacity(
        starOpacity * (isDarkMode ? 0.18 : 0.10),
      );
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );
    }

    for (final particle in particles) {
      particle.update(time);
    }

    // Draw connection lines - more subtle in light mode
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 0.15) {
          final alpha = (1 - distance / 0.15) * (isDarkMode ? 0.2 : 0.1);
          linePaint.color = HudColors.primary.withOpacity(
            alpha * (isDarkMode ? 0.35 : 0.18),
          );
          canvas.drawLine(
            Offset(p1.x * size.width, p1.y * size.height),
            Offset(p2.x * size.width, p2.y * size.height),
            linePaint,
          );
        }
      }
    }

    // Draw glowing particles with theme-appropriate glow colors
    for (final particle in particles) {
      final pos = Offset(particle.x * size.width, particle.y * size.height);
      final particleOpacity = particle.opacity.clamp(0, 1);

      // Glow effect - white for dark mode, black for light mode
      const glowColor = HudColors.primary;

      // Outer glow
      final outerGlowPaint = Paint()
        ..color =
            glowColor.withOpacity(particleOpacity * (isDarkMode ? 0.18 : 0.08))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(pos, particle.size * 6, outerGlowPaint);

      // Inner glow - only in dark mode for stronger effect
      if (isDarkMode) {
        final innerGlowPaint = Paint()
          ..color = glowColor.withOpacity(particleOpacity * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(pos, particle.size * 3.5, innerGlowPaint);
      }

      // Core particle - use base color but adjust for theme
      particlePaint.color = baseColor.withOpacity(
        particleOpacity * (isDarkMode ? 0.8 : 0.55),
      );
      canvas.drawCircle(pos, particle.size, particlePaint);
    }

    // Remove grid for cleaner look in both modes
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
