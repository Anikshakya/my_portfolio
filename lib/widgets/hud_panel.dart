import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class HudPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final double glowOpacity;
  final double? height;

  const HudPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderColor = HudColors.borderCyan,
    this.glowOpacity = 0.12,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: hudPanelDecoration(borderColor: borderColor, glowOpacity: glowOpacity),
      child: child,
    );
  }
}
