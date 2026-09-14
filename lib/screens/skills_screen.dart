import 'package:flutter/material.dart';
import '../theme/hud_theme.dart';
import '../widgets/scroll_animate.dart';
import '../widgets/app_page_header.dart';
import '../data/skills_data.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  String _selectedCategory = 'All Skills';
  final PageController _skillsPageController = PageController();
  int _currentPage = 0;

  List<Skill> get _filtered => _selectedCategory == 'All Skills'
      ? allSkills
      : allSkills.where((s) => s.category == _selectedCategory).toList();

  @override
  void dispose() {
    _skillsPageController.dispose();
    super.dispose();
  }

  // 9 items per page (3x3 grid on wide screen, 1x9 vertical list on mobile screen)
  int get _itemsPerPage => 9;
  int get _pageCount => (_filtered.length / _itemsPerPage).ceil();
  bool get _hasPreviousPage => _currentPage > 0;
  bool get _hasNextPage => _currentPage < _pageCount - 1;

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _skillsPageController.hasClients) {
        _skillsPageController.jumpToPage(0);
      }
    });
  }

  void _goToPage(int page) {
    if (!_skillsPageController.hasClients) return;
    _skillsPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final hPad = isWide ? 40.0 : 24.0;

    // Dynamic grid parameters to ensure accurate vertical centering
    final double cardExtent = isWide ? 152.0 : 160.0;
    final int rowsCount = isWide ? 3 : 9;
    const double gridSpacing = 14.0;

    // Height calculated based on responsive grid layout
    final double dynamicCarouselHeight =
        (cardExtent * rowsCount) + (gridSpacing * (rowsCount - 1)) + 16.0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPageHeader(
                  eyebrow: 'SYSTEMS DIAGNOSTICS',
                  title: 'SKILLS & STACK',
                  summary: '// ${_filtered.length} CAPABILITIES INDEXED',
                  isWide: isWide,
                  animationKey: 'skills_header',
                ),
                const SizedBox(height: 24),
                ScrollAnimate(
                  key: const ValueKey('skills_filter'),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: HudColors.selectionBarSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HudColors.selectionBarBorder,
                        ),
                      ),
                      child: SingleChildScrollView(
                        primary: false,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: skillCategories.map((cat) {
                            final isActive = _selectedCategory == cat;

                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _HoverableHudChip(
                                label: cat,
                                isActive: isActive,
                                onTap: () => _selectCategory(cat),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Carousel & Overlapping Arrows Stack
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Dynamic-height Skills Grid Container
                    SizedBox(
                      height: dynamicCarouselHeight,
                      child: PageView.builder(
                        controller: _skillsPageController,
                        itemCount: _pageCount == 0 ? 1 : _pageCount,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        itemBuilder: (_, page) {
                          final start = page * _itemsPerPage;
                          final end = (start + _itemsPerPage)
                              .clamp(0, _filtered.length);
                          final pageSkills = _filtered.sublist(start, end);

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 3 : 1,
                              mainAxisSpacing: gridSpacing,
                              crossAxisSpacing: gridSpacing,
                              mainAxisExtent: cardExtent,
                            ),
                            itemCount: pageSkills.length,
                            itemBuilder: (_, i) => ScrollAnimate(
                              key: ValueKey('skill_${pageSkills[i].name}'),
                              delay: Duration(milliseconds: i * 40),
                              child: _SkillCard(skill: pageSkills[i]),
                            ),
                          );
                        },
                      ),
                    ),

                    // Navigation Arrows (Animated after cards completion)
                    if (_hasPreviousPage)
                      Positioned(
                        left: -20,
                        child: ScrollAnimate(
                          key: ValueKey('prev_arrow_$_currentPage'),
                          delay: Duration(
                              milliseconds: (_filtered.length < 9
                                          ? _filtered.length
                                          : 9) *
                                      40 +
                                  100),
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Previous skills',
                            onPressed: () => _goToPage(_currentPage - 1),
                          ),
                        ),
                      ),

                    if (_hasNextPage)
                      Positioned(
                        right: -20,
                        child: ScrollAnimate(
                          key: ValueKey('next_arrow_$_currentPage'),
                          delay: Duration(
                              milliseconds: (_filtered.length < 9
                                          ? _filtered.length
                                          : 9) *
                                      40 +
                                  100),
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            tooltip: 'More skills',
                            onPressed: () => _goToPage(_currentPage + 1),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hoverable Wrapper for Category Chips ────────────────────────────────

class _HoverableHudChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverableHudChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_HoverableHudChip> createState() => _HoverableHudChipState();
}

class _HoverableHudChipState extends State<_HoverableHudChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = widget.isActive;
    final background = isActive
        ? HudColors.primary
        : (_isHovered ? HudColors.hoverSurface : HudColors.inactiveChipSurface);
    final border = isActive
        ? HudColors.primary
        : (_isHovered ? HudColors.hoverBorder : HudColors.inactiveChipBorder);
    final textColor = isActive
        ? (isDark ? HudColors.onPrimary : Colors.white)
        : (isDark ? HudColors.textMain : const Color(0xFF3F474D));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
            boxShadow: isActive && !isDark
                ? [
                    BoxShadow(
                      color: HudColors.primary.withValues(alpha:0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: HudTextStyles.mono(9.5, color: textColor).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hoverable Navigation Arrow ───────────────────────────────────────────

class _HoverableCarouselArrow extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HoverableCarouselArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_HoverableCarouselArrow> createState() =>
      _HoverableCarouselArrowState();
}

class _HoverableCarouselArrowState extends State<_HoverableCarouselArrow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            transform: _isHovered
                ? (Matrix4.identity()..scale(1.15))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered
                  ? HudColors.hoverSurface
                  : HudColors.elevatedSurface,
              border: Border.all(
                color: _isHovered
                    ? HudColors.cyan
                    : HudColors.cyan.withValues(alpha:0.5),
                width: _isHovered ? 2.0 : 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: HudColors.cyan.withValues(alpha:0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: HudColors.primary.withValues(alpha:0.08),
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  widget.icon,
                  color: HudColors.cyan,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Skill Card ───────────────────────────────────────────────────────────

class _SkillCard extends StatefulWidget {
  final Skill skill;
  const _SkillCard({required this.skill});

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bar;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _bar = Tween(begin: 0.0, end: widget.skill.level)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final isExpert = skill.levelLabel == 'Expert';
    final accentColor = isExpert ? HudColors.cyan : HudColors.magenta;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        transform: _hovered
            ? (Matrix4.identity()..translate(0, -5))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hovered ? HudColors.hoverSurface : HudColors.elevatedSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? HudColors.hoverBorder : HudColors.cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: accentColor.withValues(alpha:0.2), blurRadius: 18)]
              : [BoxShadow(color: HudColors.shadowColor, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: skill.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: skill.color.withValues(alpha:0.3)),
                ),
                child: Icon(Icons.bolt, color: skill.color, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skill.name,
                  style: HudTextStyles.header(11, weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha:0.08),
                  border: Border.all(color: accentColor.withValues(alpha:0.3)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  skill.levelLabel,
                  style: HudTextStyles.mono(7, color: accentColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              skill.description,
              style: HudTextStyles.body(10, color: HudColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _bar,
              builder: (_, __) => Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _bar.value,
                        minHeight: 4,
                        backgroundColor:
                            HudColors.elevatedSurface.withValues(alpha:0.5),
                        valueColor: AlwaysStoppedAnimation(skill.color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(skill.level * 100).round()}%',
                    style: HudTextStyles.mono(8)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: skill.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: HudColors.cyan.withValues(alpha:0.04),
                          border: Border.all(
                              color: HudColors.cyan.withValues(alpha:0.12)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(tag, style: HudTextStyles.mono(7)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
