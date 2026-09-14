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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Choose appropriate contrast color based on theme
    final lineColor = isDarkMode ? HudColors.primary : const Color(0xFF0F172A); // Dark slate for light mode

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => IgnorePointer(
        ignoring: true,
        child: CustomPaint(
          painter: _HudGridBackgroundPainter(
            _controller.value,
            lineColor,
            isDarkMode,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HudGridBackgroundPainter extends CustomPainter {
  final double progress;
  final Color lineColor;
  final bool isDarkMode;

  _HudGridBackgroundPainter(
    this.progress,
    this.lineColor,
    this.isDarkMode,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Deep Base Background
    final bgPaint = Paint()
      ..color = isDarkMode ? HudColors.background : HudColors.lightBackground;
    canvas.drawRect(rect, bgPaint);

    // 2. Atmospheric Radial Glow
    final radialGradient = RadialGradient(
      center: const Alignment(0.0, -0.4),
      radius: 0.9,
      colors: [
        lineColor.withValues(alpha:isDarkMode ? 0.08 : 0.03),
        lineColor.withValues(alpha:0.0),
      ],
    );
    final radialPaint = Paint()
      ..shader = radialGradient.createShader(rect);
    canvas.drawRect(rect, radialPaint);

    // 3. Precision Cyber-Grid (Slightly higher opacity in light mode for crisp visibility)
    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha:isDarkMode ? 0.05 : 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 50.0;
    
    // Vertical Grid Lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal Grid Lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 4. Subtle Animated Scanning Horizon Line
    final scanY = (progress * size.height * 1.5) - (size.height * 0.25);
    if (scanY >= 0 && scanY <= size.height) {
      final scanPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            lineColor.withValues(alpha:0.0),
            lineColor.withValues(alpha:isDarkMode ? 0.15 : 0.12),
            lineColor.withValues(alpha:0.0),
          ],
        ).createShader(Rect.fromLTWH(0, scanY, size.width, 2))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudGridBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.lineColor != lineColor;
  }
}