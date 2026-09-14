import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/scroll_animate.dart';
import '../widgets/app_page_header.dart';
import '../data/experience_data.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final exp = experiences[_selectedIndex];
    final colorScheme = Theme.of(context).colorScheme;

    final cyanColor = colorScheme.primary != Colors.transparent
        ? colorScheme.primary
        : HudColors.cyan;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final hPad = isWide ? 40.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppPageHeader(
                    eyebrow: 'CAREER ARCHIVE',
                    title: 'WORK EXPERIENCE',
                    summary:
                        '// ${experiences.length} LOGS FROM PAST TO PRESENT',
                    isWide: isWide,
                    animationKey: 'exp_header',
                  ),
                  const SizedBox(height: 32),
                  isWide
                      ? _wideLayout(exp, colorScheme, cyanColor)
                      : _narrowLayout(exp, colorScheme, cyanColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wideLayout(
          Experience exp, ColorScheme colorScheme, Color cyanColor) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: ScrollAnimate(
              key: const ValueKey('exp_timeline_list'),
              child: _timelineList(colorScheme, cyanColor),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ScrollAnimate(
              key: ValueKey('exp_detail_$_selectedIndex'),
              child: _detailPanel(exp, colorScheme, cyanColor, isWide: true),
            ),
          ),
        ],
      );

  Widget _narrowLayout(
          Experience exp, ColorScheme colorScheme, Color cyanColor) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScrollAnimate(
            key: const ValueKey('exp_timeline_list_mobile'),
            child: _timelineList(colorScheme, cyanColor),
          ),
          const SizedBox(height: 16),
          ScrollAnimate(
            key: ValueKey('exp_detail_mobile_$_selectedIndex'),
            child: _detailPanel(exp, colorScheme, cyanColor, isWide: false),
          ),
        ],
      );

  Widget _timelineList(ColorScheme colorScheme, Color cyanColor) {
    return HudPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TIMELINE NODES',
                  style: HudTextStyles.mono(10, color: HudColors.textMuted)
                      .copyWith(letterSpacing: 1.2)),
              Text('[${experiences.length} LOGS]',
                  style: HudTextStyles.mono(9, color: cyanColor)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Positioned(
                left: 17,
                top: 8,
                bottom: 8,
                child: CustomPaint(
                  painter: _TimelineLinePainter(lineColor: cyanColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(experiences.length, (i) {
                  final e = experiences[i];
                  final isSelected = _selectedIndex == i;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _TimelineNodeTile(
                      experience: e,
                      isSelected: isSelected,
                      colorScheme: colorScheme,
                      cyanColor: cyanColor,
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: cyanColor.withOpacity(0.2), height: 1),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'SELECT NODE TO VIEW TELEMETRY',
              style: HudTextStyles.mono(9, color: HudColors.textMuted)
                  .copyWith(letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPanel(Experience exp, ColorScheme colorScheme, Color cyanColor,
      {required bool isWide}) {
    return HudPanel(
      borderColor: exp.isCurrent
          ? HudColors.green.withOpacity(0.4)
          : cyanColor.withOpacity(0.3),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child:
                            _buildTitleAndCompany(exp, colorScheme, cyanColor)),
                    const SizedBox(width: 12),
                    _buildDateBadge(exp, colorScheme, cyanColor),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleAndCompany(exp, colorScheme, cyanColor),
                    const SizedBox(height: 12),
                    _buildDateBadge(exp, colorScheme, cyanColor),
                  ],
                ),
          const SizedBox(height: 16),
          Divider(color: cyanColor.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            exp.description,
            style: HudTextStyles.body(13.5, color: HudColors.textMuted)
                .copyWith(height: 1.6, letterSpacing: 0.2),
          ),
          const SizedBox(height: 20),
          Text(
            'KEY MILESTONES & ACHIEVEMENTS',
            style: HudTextStyles.mono(10, color: HudColors.textMuted)
                .copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          ...exp.achievements.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cyanColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: cyanColor.withOpacity(0.8), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a,
                      style:
                          HudTextStyles.body(13, color: colorScheme.onSurface)
                              .copyWith(height: 1.5, letterSpacing: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: cyanColor.withOpacity(0.15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('STACK:',
                  style: HudTextStyles.mono(9.5, color: HudColors.textMuted)
                      .copyWith(letterSpacing: 1.0)),
              ...exp.technologies.map(
                (t) => _HoverableTechChip(
                    label: t, colorScheme: colorScheme, cyanColor: cyanColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                label: '◄ NEXT LOG',
                enabled: _selectedIndex > 0,
                colorScheme: colorScheme,
                cyanColor: cyanColor,
                onTap: () => setState(() => _selectedIndex--),
              ),
              Text(
                'LOG ${_selectedIndex + 1} / ${experiences.length}',
                style: HudTextStyles.mono(10, color: HudColors.textMuted)
                    .copyWith(letterSpacing: 1.2),
              ),
              _NavButton(
                label: 'PREV LOG ►',
                enabled: _selectedIndex < experiences.length - 1,
                colorScheme: colorScheme,
                cyanColor: cyanColor,
                onTap: () => setState(() => _selectedIndex++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndCompany(
      Experience exp, ColorScheme colorScheme, Color cyanColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              exp.title,
              style: HudTextStyles.header(20,
                      color: colorScheme.onSurface, weight: FontWeight.w600)
                  .copyWith(letterSpacing: 0.5),
            ),
            if (exp.isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: HudColors.green.withOpacity(0.12),
                  border: Border.all(color: HudColors.green.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'ACTIVE',
                  style: HudTextStyles.mono(8, color: HudColors.green)
                      .copyWith(letterSpacing: 1.0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_rounded, size: 14, color: cyanColor),
                const SizedBox(width: 6),
                Text(exp.company,
                    style: HudTextStyles.body(13, color: cyanColor)
                        .copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: HudColors.textMuted),
                const SizedBox(width: 4),
                Text(exp.location,
                    style: HudTextStyles.body(12, color: HudColors.textMuted)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateBadge(
      Experience exp, ColorScheme colorScheme, Color cyanColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cyanColor.withOpacity(0.06),
        border: Border.all(color: cyanColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${exp.startDate} – ${exp.endDate}',
        style: HudTextStyles.mono(10, color: colorScheme.onSurface)
            .copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

// ── Timeline Node Widget ─────────────────────────────────────────

class _TimelineNodeTile extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final ColorScheme colorScheme;
  final Color cyanColor;
  final VoidCallback onTap;

  _TimelineNodeTile({
    required this.experience,
    required this.isSelected,
    required this.colorScheme,
    required this.cyanColor,
    required this.onTap,
  });

  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, hovered, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected
                    ? cyanColor.withOpacity(0.12)
                    : (hovered
                        ? cyanColor.withOpacity(0.04)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? cyanColor
                      : (hovered
                          ? cyanColor.withOpacity(0.3)
                          : Colors.transparent),
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isSelected ? 14 : (hovered ? 12 : 10),
                    height: isSelected ? 14 : (hovered ? 12 : 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: experience.isCurrent
                          ? HudColors.green
                          : (isSelected
                              ? cyanColor
                              : (hovered
                                  ? cyanColor.withOpacity(0.6)
                                  : colorScheme.surfaceContainerHighest)),
                      border: Border.all(
                        color: experience.isCurrent
                            ? Colors.white
                            : (isSelected
                                ? cyanColor
                                : cyanColor.withOpacity(0.4)),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.title,
                          style: HudTextStyles.body(
                            12,
                            color: isSelected
                                ? colorScheme.onSurface
                                : (hovered ? cyanColor : colorScheme.onSurface),
                          ).copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${experience.company} · ${experience.startDate}',
                          style: HudTextStyles.mono(
                            9,
                            color: isSelected ? cyanColor : HudColors.textMuted,
                          ).copyWith(letterSpacing: 0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.chevron_right_rounded,
                        color: cyanColor, size: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Hoverable Tech Chip ──────────────────────────────────────────

class _HoverableTechChip extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;
  final Color cyanColor;

  _HoverableTechChip({
    required this.label,
    required this.colorScheme,
    required this.cyanColor,
  });

  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFF5C542);

    return ValueListenableBuilder<bool>(
      valueListenable: _isHovered,
      builder: (context, hovered, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, hovered ? -1.5 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: hovered ? goldColor : colorScheme.surface.withOpacity(0.4),
            border: Border.all(
              color: hovered ? goldColor : cyanColor.withOpacity(0.25),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: goldColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: HudTextStyles.mono(
              10,
              color: hovered ? Colors.white : colorScheme.onSurface,
            ).copyWith(
              fontWeight: hovered ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.9,
            ),
          ),
        );
      },
    );
  }
}

// ── Navigation Button ────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final ColorScheme colorScheme;
  final Color cyanColor;
  final VoidCallback onTap;

  _NavButton({
    required this.label,
    required this.enabled,
    required this.colorScheme,
    required this.cyanColor,
    required this.onTap,
  });

  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => enabled ? _isHovered.value = true : null,
      onExit: (_) => _isHovered.value = false,
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isHovered,
            builder: (context, hovered, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hovered
                      ? cyanColor.withOpacity(0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: hovered ? cyanColor : cyanColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: HudTextStyles.mono(
                    9.5,
                    color: hovered ? cyanColor : colorScheme.onSurface,
                  ).copyWith(letterSpacing: 1.0),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Timeline Line Custom Painter ──────────────────────────────────

class _TimelineLinePainter extends CustomPainter {
  final Color lineColor;

  _TimelineLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
