import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';
import '../widgets/scroll_animate.dart';
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
    final isWide = MediaQuery.of(context).size.width > 900;
    final hPad = isWide ? 40.0 : 16.0;
    final colorScheme = Theme.of(context).colorScheme;
    final headerTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CAREER LOGS // ORBIT TIMELINE', style: HudTextStyles.mono(10)),
        const SizedBox(height: 4),
        GlowText('WORK EXPERIENCE',
            style: HudTextStyles.header(18),
            glowColor: colorScheme.secondary != Colors.transparent
                ? colorScheme.secondary
                : HudColors.cyan),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ScrollAnimate(
                key: const ValueKey('exp_header'),
                child: HudPanel(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isWide) Expanded(child: headerTitle) else headerTitle,
                      if (!isWide) const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: HudColors.green.withOpacity(0.08),
                          border: Border.all(
                              color: HudColors.green.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: HudColors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: HudColors.green, blurRadius: 6)
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('ACTIVE',
                                style: HudTextStyles.mono(10,
                                    color: HudColors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isWide
                  ? _wideLayout(exp, colorScheme)
                  : _narrowLayout(exp, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // Wide layout using Row with aligned children height via Container/Expanded constraints
  Widget _wideLayout(Experience exp, ColorScheme colorScheme) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: ScrollAnimate(
              key: const ValueKey('exp_timeline_list'),
              child: _timelineList(colorScheme),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ScrollAnimate(
              key: ValueKey('exp_detail_$_selectedIndex'),
              child: _detailPanel(exp, colorScheme, isWide: true),
            ),
          ),
        ],
      );

  Widget _narrowLayout(Experience exp, ColorScheme colorScheme) => Column(
        children: [
          ScrollAnimate(
            key: const ValueKey('exp_timeline_list_mobile'),
            child: _timelineList(colorScheme),
          ),
          const SizedBox(height: 16),
          ScrollAnimate(
            key: ValueKey('exp_detail_mobile_$_selectedIndex'),
            child: _detailPanel(exp, colorScheme, isWide: false),
          ),
        ],
      );

  Widget _timelineList(ColorScheme colorScheme) {
    final cyanColor = colorScheme.primary != Colors.transparent
        ? colorScheme.primary
        : HudColors.cyan;

    return HudPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TIMELINE NODES', style: HudTextStyles.mono(10)),
              Text('[${experiences.length} LOGS]',
                  style: HudTextStyles.mono(9, color: cyanColor)),
            ],
          ),
          const SizedBox(height: 16),
          // Wrapped nodes column inside a consistent non-expanded structural wrapper or tightly wrapped list
          Stack(
            children: [
              // Cyberpunk Vertical Connecting Track Line spanning full height
              Positioned(
                left: 17,
                top: 8,
                bottom: 8,
                child: CustomPaint(
                  painter: _TimelineLinePainter(lineColor: cyanColor),
                ),
              ),

              // Interactive Nodes List
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
              style: HudTextStyles.mono(9, color: HudColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPanel(Experience exp, ColorScheme colorScheme,
      {required bool isWide}) {
    final cyanColor = colorScheme.primary != Colors.transparent
        ? colorScheme.primary
        : HudColors.cyan;

    return HudPanel(
      borderColor: exp.isCurrent
          ? HudColors.green.withOpacity(0.4)
          : HudColors.borderCyan,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isWide
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              if (isWide)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            exp.title,
                            style: HudTextStyles.header(16,
                                color: Colors.white, weight: FontWeight.w700),
                          ),
                          if (exp.isCurrent) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: HudColors.green.withOpacity(0.15),
                                border: Border.all(color: HudColors.green),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: HudTextStyles.mono(8,
                                    color: HudColors.green),
                              ),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_rounded,
                                  size: 14, color: cyanColor),
                              const SizedBox(width: 6),
                              Text(exp.company,
                                  style:
                                      HudTextStyles.body(13, color: cyanColor)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: HudColors.textMuted),
                              const SizedBox(width: 4),
                              Text(exp.location,
                                  style: HudTextStyles.body(12,
                                      color: HudColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          exp.title,
                          style: HudTextStyles.header(16,
                              color: Colors.white, weight: FontWeight.w700),
                        ),
                        if (exp.isCurrent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: HudColors.green.withOpacity(0.15),
                              border: Border.all(color: HudColors.green),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'ACTIVE',
                              style:
                                  HudTextStyles.mono(8, color: HudColors.green),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded,
                                size: 14, color: cyanColor),
                            const SizedBox(width: 6),
                            Text(exp.company,
                                style:
                                    HudTextStyles.body(13, color: cyanColor)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: HudColors.textMuted),
                            const SizedBox(width: 4),
                            Text(exp.location,
                                style: HudTextStyles.body(12,
                                    color: HudColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.only(top: isWide ? 0 : 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cyanColor.withOpacity(0.08),
                    border: Border.all(color: cyanColor.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${exp.startDate} – ${exp.endDate}',
                    style: HudTextStyles.mono(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: cyanColor.withOpacity(0.2)),
          const SizedBox(height: 8),
          Text(
            exp.description,
            style: HudTextStyles.body(13).copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            'KEY MILESTONES & ACHIEVEMENTS:',
            style: HudTextStyles.mono(10, color: HudColors.textMuted),
          ),
          const SizedBox(height: 6),
          ...exp.achievements.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cyanColor,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: cyanColor.withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a,
                      style: HudTextStyles.body(12.5).copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: cyanColor.withOpacity(0.15)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('STACK:',
                  style: HudTextStyles.mono(9.5, color: HudColors.textMuted)),
              ...exp.technologies.map(
                (t) => _HoverableTechChip(label: t, colorScheme: colorScheme),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: isWide
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
            children: [
              _NavButton(
                label: '◄ NEXT',
                enabled: _selectedIndex > 0,
                colorScheme: colorScheme,
                onTap: () => setState(() => _selectedIndex--),
              ),
              Text(
                'LOG ${_selectedIndex + 1} OF ${experiences.length}',
                style: HudTextStyles.mono(10, color: HudColors.textMuted),
              ),
              _NavButton(
                label: 'PREVIOUS ►',
                enabled: _selectedIndex < experiences.length - 1,
                colorScheme: colorScheme,
                onTap: () => setState(() => _selectedIndex++),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Timeline Node Widget ─────────────────────────────────────────

class _TimelineNodeTile extends StatefulWidget {
  final Experience experience;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _TimelineNodeTile({
    required this.experience,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<_TimelineNodeTile> createState() => _TimelineNodeTileState();
}

class _TimelineNodeTileState extends State<_TimelineNodeTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSel = widget.isSelected;
    final exp = widget.experience;
    final cyanColor = widget.colorScheme.primary != Colors.transparent
        ? widget.colorScheme.primary
        : HudColors.cyan;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: isSel
                ? cyanColor.withOpacity(0.14)
                : (_isHovered
                    ? cyanColor.withOpacity(0.06)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSel
                  ? cyanColor
                  : (_isHovered
                      ? cyanColor.withOpacity(0.4)
                      : Colors.transparent),
            ),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: cyanColor.withOpacity(0.2),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSel ? 16 : (_isHovered ? 14 : 12),
                height: isSel ? 16 : (_isHovered ? 14 : 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: exp.isCurrent
                      ? HudColors.green
                      : (isSel
                          ? cyanColor
                          : (_isHovered
                              ? cyanColor.withOpacity(0.6)
                              : const Color(0xFF060E22))),
                  border: Border.all(
                    color: exp.isCurrent
                        ? Colors.white
                        : (isSel ? cyanColor : cyanColor.withOpacity(0.5)),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: exp.isCurrent
                          ? HudColors.green
                          : (isSel || _isHovered
                              ? cyanColor
                              : Colors.transparent),
                      blurRadius: isSel ? 10 : 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.title,
                      style: HudTextStyles.body(
                        12,
                        color: isSel
                            ? Colors.white
                            : (_isHovered ? cyanColor : HudColors.textMain),
                      ).copyWith(
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exp.company} · ${exp.startDate}',
                      style: HudTextStyles.mono(
                        9,
                        color: isSel ? cyanColor : HudColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSel)
                Icon(Icons.chevron_right_rounded, color: cyanColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hoverable Tech Chip ──────────────────────────────────────────

class _HoverableTechChip extends StatefulWidget {
  final String label;
  final ColorScheme colorScheme;

  const _HoverableTechChip({
    required this.label,
    required this.colorScheme,
  });

  @override
  State<_HoverableTechChip> createState() => _HoverableTechChipState();
}

class _HoverableTechChipState extends State<_HoverableTechChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cyanColor = widget.colorScheme.primary != Colors.transparent
        ? widget.colorScheme.primary
        : HudColors.cyan;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _isHovered
              ? cyanColor.withOpacity(0.15)
              : const Color(0xCC020614),
          border: Border.all(
            color: _isHovered ? cyanColor : cyanColor.withOpacity(0.25),
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          widget.label,
          style: HudTextStyles.mono(
            10,
            color: _isHovered ? cyanColor : HudColors.textMain,
          ),
        ),
      ),
    );
  }
}

// ── Nav Button ──────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.enabled,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cyanColor = widget.colorScheme.primary != Colors.transparent
        ? widget.colorScheme.primary
        : HudColors.cyan;

    return MouseRegion(
      onEnter: (_) => widget.enabled ? setState(() => _isHovered = true) : null,
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _isHovered ? cyanColor.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: _isHovered ? cyanColor : cyanColor.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: cyanColor.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.label,
              style: HudTextStyles.mono(
                9.5,
                color: _isHovered ? cyanColor : HudColors.textMain,
              ),
            ),
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
      ..color = lineColor.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
