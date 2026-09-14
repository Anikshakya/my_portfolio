import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _PremiumBackgroundPainter(
          Theme.of(context).brightness == Brightness.dark,
          _controller.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  final bool isDark;
  final double phase;
  _PremiumBackgroundPainter(this.isDark, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final base = isDark ? HudColors.background : HudColors.lightBackground;
    final glow = isDark ? const Color(0xFF3B3324) : const Color(0xFFE8DCC0);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glow.withValues(alpha:0.2 + phase * 0.08), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
    final linePaint = Paint()
      ..color = HudColors.primary.withValues(alpha:isDark ? 0.035 : 0.06)
      ..strokeWidth = 1;
    for (var index = 1; index < 12; index++) {
      final x = size.width * index / 12;
      canvas.drawLine(
          Offset(x, 0), Offset(x - size.height * 0.3, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(_PremiumBackgroundPainter old) =>
      old.isDark != isDark || old.phase != phase;
}
