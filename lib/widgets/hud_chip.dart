import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class HudChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const HudChip(
      {super.key,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? HudColors.primary : HudColors.chipSurface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive ? HudColors.primary : HudColors.chipBorder,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: HudColors.primary.withOpacity(0.3), blurRadius: 8)
                ]
              : [],
        ),
        child: Text(
          label,
          style: HudTextStyles.mono(10,
                  color: isActive ? HudColors.onPrimary : HudColors.primary)
              .copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
