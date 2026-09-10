import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/hud_chip.dart';
import '../widgets/glow_text.dart';
import '../data/skills_data.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});
  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  String _selectedCategory = 'All Skills';

  List<Skill> get _filtered => _selectedCategory == 'All Skills'
      ? allSkills
      : allSkills.where((s) => s.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          HudPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SYSTEMS_DIAGNOSTICS // SKILLS_MATRIX', style: HudTextStyles.mono(10)),
                    const SizedBox(height: 4),
                    GlowText('TECHNICAL SKILLS & STACK',
                        style: HudTextStyles.header(16), glowColor: HudColors.cyan),
                  ],
                ),
                Text('${_filtered.length} / ${allSkills.length} NODES',
                    style: HudTextStyles.mono(10)),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 12),
          // Category chips
          HudPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: skillCategories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: HudChip(
                        label: cat,
                        isActive: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    )).toList(),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 12),
          // Skill cards grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _SkillCard(skill: _filtered[i])
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: i * 50))
                .slideY(begin: 0.06),
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatefulWidget {
  final Skill skill;
  const _SkillCard({required this.skill});
  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _barCtrl;
  late Animation<double> _barAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _barAnim = Tween(begin: 0.0, end: widget.skill.level)
        .animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final isExpert = skill.levelLabel == 'Expert';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        transform: _hovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xA6040818) : const Color(0x80020208),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: _hovered ? HudColors.cyan : HudColors.cyan.withOpacity(0.15),
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: HudColors.cyan.withOpacity(0.25), blurRadius: 14)]
              : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon, name, badge
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: skill.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: skill.color.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.bolt, color: skill.color, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(skill.name,
                      style: HudTextStyles.header(11, weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isExpert ? HudColors.cyan : HudColors.magenta).withOpacity(0.1),
                    border: Border.all(
                        color: (isExpert ? HudColors.cyan : HudColors.magenta).withOpacity(0.35)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(skill.levelLabel,
                      style: HudTextStyles.mono(8,
                          color: isExpert ? HudColors.cyan : HudColors.magenta)
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Description
            Expanded(
              child: Text(skill.description,
                  style: HudTextStyles.body(11, color: HudColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 6),
            // Progress bar
            AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _barAnim.value,
                            minHeight: 5,
                            backgroundColor: Colors.white.withOpacity(0.06),
                            valueColor: AlwaysStoppedAnimation(skill.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(skill.level * 100).round()}%',
                          style: HudTextStyles.mono(9, color: HudColors.textMain)
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Tags
            Wrap(
              spacing: 4,
              runSpacing: 3,
              children: skill.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: HudColors.cyan.withOpacity(0.05),
                      border: Border.all(color: HudColors.cyan.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(tag, style: HudTextStyles.mono(8)),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
