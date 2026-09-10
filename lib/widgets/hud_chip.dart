import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class HudChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const HudChip({super.key, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? HudColors.cyan : const Color(0x1100F0FF),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive ? HudColors.cyan : const Color(0x4400F0FF),
          ),
          boxShadow: isActive ? [BoxShadow(color: HudColors.cyan.withOpacity(0.35), blurRadius: 8)] : [],
        ),
        child: Text(
          label,
          style: HudTextStyles.mono(10, color: isActive ? const Color(0xFF020208) : HudColors.cyan).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
