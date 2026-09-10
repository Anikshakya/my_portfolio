import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';
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
    final isWide = MediaQuery.of(context).size.width > 720;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          HudPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CAREER LOGS // ORBIT TIMELINE', style: HudTextStyles.mono(10)),
                    const SizedBox(height: 4),
                    GlowText('WORK EXPERIENCE',
                        style: HudTextStyles.header(18),
                        glowColor: HudColors.cyan),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HudColors.green.withOpacity(0.08),
                    border: Border.all(color: HudColors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: HudColors.green,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: HudColors.green, blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('ACTIVE', style: HudTextStyles.mono(10, color: HudColors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 16),
          isWide
              ? _wideLayout(exp)
              : _narrowLayout(exp),
        ],
      ),
    );
  }

  Widget _wideLayout(Experience exp) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 280, child: _timelineList()),
          const SizedBox(width: 16),
          Expanded(child: _detailPanel(exp)),
        ],
      );

  Widget _narrowLayout(Experience exp) => Column(
        children: [
          _timelineList(),
          const SizedBox(height: 12),
          _detailPanel(exp),
        ],
      );

  Widget _timelineList() => HudPanel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TIMELINE NODES [${experiences.length}]',
                style: HudTextStyles.mono(10)),
            const SizedBox(height: 8),
            ...List.generate(experiences.length, (i) {
              final e = experiences[i];
              final isSelected = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? HudColors.cyan.withOpacity(0.12) : const Color(0x19020614),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? HudColors.cyan : HudColors.cyan.withOpacity(0.12),
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: HudColors.cyan.withOpacity(0.2), blurRadius: 12)]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: e.isCurrent ? 14 : 10,
                        height: e.isCurrent ? 14 : 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.isCurrent ? HudColors.green : isSelected ? HudColors.cyan : const Color(0xFF060E22),
                          border: Border.all(
                            color: e.isCurrent ? Colors.white : isSelected ? HudColors.cyan : HudColors.cyan.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: e.isCurrent ? HudColors.green : isSelected ? HudColors.cyan : Colors.transparent,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: HudTextStyles.body(12,
                                    color: isSelected ? Colors.white : HudColors.textMain)
                                    .copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${e.company} · ${e.startDate}–${e.endDate}',
                                style: HudTextStyles.mono(9, color: HudColors.textMuted)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.play_arrow, color: HudColors.cyan, size: 14),
                    ],
                  ),
                ),
              );
            }),
            const Divider(color: Color(0x2500F0FF), height: 16),
            Text('SELECT NODE TO VIEW TELEMETRY',
                style: HudTextStyles.mono(9, color: HudColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 100.ms);

  Widget _detailPanel(Experience exp) => HudPanel(
        borderColor: exp.isCurrent ? HudColors.green.withOpacity(0.4) : HudColors.borderCyan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(exp.title,
                                style: HudTextStyles.header(16, color: Colors.white, weight: FontWeight.w700)),
                          ),
                          if (exp.isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: HudColors.green.withOpacity(0.15),
                                border: Border.all(color: HudColors.green),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text('ACTIVE', style: HudTextStyles.mono(8, color: HudColors.green)),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('🏢 ${exp.company}   📍 ${exp.location}',
                          style: HudTextStyles.body(13, color: HudColors.cyan)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: HudColors.cyan.withOpacity(0.08),
                    border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${exp.startDate} – ${exp.endDate}',
                      style: HudTextStyles.mono(10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0x2500F0FF)),
            const SizedBox(height: 10),
            Text(exp.description, style: HudTextStyles.body(13)),
            const SizedBox(height: 14),
            Text('KEY MILESTONES & ACHIEVEMENTS:',
                style: HudTextStyles.mono(10, color: HudColors.textMuted)),
            const SizedBox(height: 8),
            ...exp.achievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('▶ ', style: TextStyle(color: HudColors.cyan, fontSize: 11)),
                      Expanded(child: Text(a, style: HudTextStyles.body(12.5))),
                    ],
                  ),
                )),
            const Divider(color: Color(0x1AFFFFFF), height: 24),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Text('STACK:', style: HudTextStyles.mono(9.5, color: HudColors.textMuted)),
                ...exp.technologies.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xCC020614),
                        border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(t, style: HudTextStyles.mono(10)),
                    )),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _selectedIndex > 0 ? () => setState(() => _selectedIndex--) : null,
                  child: Opacity(
                    opacity: _selectedIndex > 0 ? 1.0 : 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: HudColors.cyan.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('◄ NEXT', style: HudTextStyles.mono(9.5)),
                    ),
                  ),
                ),
                Text('LOG ${_selectedIndex + 1} OF ${experiences.length}',
                    style: HudTextStyles.mono(10, color: HudColors.textMuted)),
                GestureDetector(
                  onTap: _selectedIndex < experiences.length - 1
                      ? () => setState(() => _selectedIndex++)
                      : null,
                  child: Opacity(
                    opacity: _selectedIndex < experiences.length - 1 ? 1.0 : 0.3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: HudColors.cyan.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('PREVIOUS ►', style: HudTextStyles.mono(9.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
}
