import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';
import 'glow_text.dart';
import 'scroll_animate.dart';

class AppPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String summary;
  final bool isWide;
  final String animationKey;

  const AppPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.isWide,
    required this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? HudColors.textMuted : const Color(0xFF68747C);
    final titleColor = isDark ? HudColors.textMain : const Color(0xFF151A1E);

    return ScrollAnimate(
      key: ValueKey(animationKey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            eyebrow,
            style: HudTextStyles.mono(10, color: muted).copyWith(
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          if (isDark)
            GlowText(
              title,
              style: HudTextStyles.header(isWide ? 36 : 24).copyWith(
                letterSpacing: 3.0,
                fontWeight: FontWeight.w300,
                color: titleColor,
              ),
              glowColor: HudColors.primary,
            )
          else
            Text(
              title,
              style: HudTextStyles.header(isWide ? 36 : 24).copyWith(
                letterSpacing: 3.0,
                fontWeight: FontWeight.w300,
                color: titleColor,
              ),
            ),
          const SizedBox(height: 7),
          Text(
            summary,
            style: HudTextStyles.mono(10, color: muted).copyWith(
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
