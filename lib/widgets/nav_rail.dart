import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';

class HudNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HudNavRail(
      {super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.person_outline_rounded, 'ABOUT'),
    (Icons.work_outline_rounded, 'CAREER'),
    (Icons.grid_view_rounded, 'PROJECTS'),
    (Icons.bolt_rounded, 'SKILLS'),
    (Icons.mail_outline_rounded, 'CONTACT'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      color: HudColors.surface.withOpacity(0.95),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isActive
                    ? HudColors.cyan.withOpacity(0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: isActive ? HudColors.cyan : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _items[i].$1,
                    color: isActive ? HudColors.cyan : HudColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].$2,
                    style: HudTextStyles.mono(6,
                        color: isActive ? HudColors.cyan : HudColors.textMuted),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
