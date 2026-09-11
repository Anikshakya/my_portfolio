import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';
import '../widgets/scroll_animate.dart';
import '../data/projects_data.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showAll = false;
  final PageController _projectsPageController = PageController();
  int _currentPage = 0;

  // 6 items on desktop (3x2 grid), 2 items on mobile (1x2 grid)
  int _getItemsPerPage(bool isWide) => isWide ? 6 : 2;

  int _getPageCount(bool isWide) =>
      (_displayedProjects.length / _getItemsPerPage(isWide)).ceil();

  List<Project> get _displayedProjects =>
      _showAll ? projects : projects.where((p) => p.isShowcase).toList();

  @override
  void dispose() {
    _projectsPageController.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDetail(Project proj) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProjectModal(proj: proj, onLaunch: _launch),
    );
  }

  void _goToPage(int page) {
    if (!_projectsPageController.hasClients) return;
    _projectsPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final hPad = isWide ? 56.0 : 24.0;
    final displayed = _displayedProjects;
    final itemsPerPage = _getItemsPerPage(isWide);
    final pageCount = _getPageCount(isWide);

    final hasPreviousPage = _currentPage > 0;
    final hasNextPage = _currentPage < pageCount - 1;

    // Dynamic grid extent based on screen width
    final double dynamicExtent = isWide ? 248.0 : 250.0;
    final double dynamicCarouselHeight = (dynamicExtent * 2) + 24.0;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _pageHeader(),
                const SizedBox(height: 20),

                // Filter tabs
                ScrollAnimate(
                  key: const ValueKey('proj_tabs'),
                  child: Row(
                    children: [
                      _HoverableTab(
                        label: 'Showcase',
                        active: !_showAll,
                        onTap: () => _selectTab(false),
                      ),
                      const SizedBox(width: 8),
                      _HoverableTab(
                        label: 'All Projects',
                        active: _showAll,
                        onTap: () => _selectTab(true),
                      ),
                      const Spacer(),
                      Text(
                        '${displayed.length} projects',
                        style: HudTextStyles.mono(10, color: HudColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dynamic-height carousel container strictly holding 2 rows
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: dynamicCarouselHeight,
                      child: PageView.builder(
                        controller: _projectsPageController,
                        itemCount: pageCount == 0 ? 1 : pageCount,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        itemBuilder: (_, page) {
                          final start = page * itemsPerPage;
                          final end =
                              (start + itemsPerPage).clamp(0, displayed.length);
                          final pageProjects = displayed.sublist(start, end);

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 3 : 1,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: dynamicExtent, // Fully dynamic card extent
                            ),
                            itemCount: pageProjects.length,
                            itemBuilder: (_, i) => ScrollAnimate(
                              key: ValueKey('proj_card_${pageProjects[i].id}'),
                              delay: Duration(milliseconds: i * 60),
                              child: _ProjectCard(
                                project: pageProjects[i],
                                onTap: () => _showDetail(pageProjects[i]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Navigation Arrows (Animated after cards completion)
                    if (hasPreviousPage)
                      Positioned(
                        left: -20,
                        child: ScrollAnimate(
                          key: ValueKey('prev_arrow_$_currentPage'),
                          delay: Duration(
                              milliseconds:
                                  (itemsPerPage < displayed.length
                                              ? itemsPerPage
                                              : displayed.length) *
                                          60 +
                                      100),
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Previous projects',
                            onPressed: () => _goToPage(_currentPage - 1),
                          ),
                        ),
                      ),

                    if (hasNextPage)
                      Positioned(
                        right: -20,
                        child: ScrollAnimate(
                          key: ValueKey('next_arrow_$_currentPage'),
                          delay: Duration(
                              milliseconds:
                                  (itemsPerPage < displayed.length
                                              ? itemsPerPage
                                              : displayed.length) *
                                          60 +
                                      100),
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            tooltip: 'More projects',
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

  void _selectTab(bool showAll) {
    setState(() {
      _showAll = showAll;
      _currentPage = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _projectsPageController.hasClients) {
        _projectsPageController.jumpToPage(0);
      }
    });
  }

  Widget _pageHeader() => ScrollAnimate(
        key: const ValueKey('projects_header'),
        child: SizedBox(
          width: double.infinity,
          child: HudPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELECTED WORK // PROJECT ARCHIVE',
                    style: HudTextStyles.mono(10)),
                const SizedBox(height: 4),
                GlowText('PROJECTS',
                    style: HudTextStyles.header(18), glowColor: HudColors.cyan),
              ],
            ),
          ),
        ),
      );
}

// ── Hoverable Tab Filter ───────────────────────────────────────────

class _HoverableTab extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _HoverableTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_HoverableTab> createState() => _HoverableTabState();
}

class _HoverableTabState extends State<_HoverableTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.active
                  ? HudColors.cyan
                  : (_isHovered
                      ? HudColors.cyan.withOpacity(0.12)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.active
                    ? HudColors.cyan
                    : (_isHovered
                        ? HudColors.cyan.withOpacity(0.6)
                        : HudColors.cyan.withOpacity(0.3)),
              ),
            ),
            child: Text(
              widget.label,
              style: HudTextStyles.mono(
                10,
                color: widget.active ? const Color(0xFF020208) : HudColors.cyan,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hoverable Carousel Navigation Arrow ──────────────────────────────

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
                  ? HudColors.cyan.withOpacity(0.2)
                  : HudColors.background.withOpacity(0.95),
              border: Border.all(
                color: _isHovered
                    ? HudColors.cyan
                    : HudColors.cyan.withOpacity(0.5),
                width: _isHovered ? 2.0 : 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: HudColors.cyan.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
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

// ── Project Card ─────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isLive = widget.project.status == 'STORE RELEASE';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          transform: _hovered
              ? (Matrix4.identity()..translate(0, -5))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF060F24) : HudColors.panelBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? HudColors.cyan : HudColors.borderCyan,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: HudColors.cyan.withOpacity(0.2), blurRadius: 20)
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4), blurRadius: 10)
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: HudColors.cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: HudColors.cyan.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.apps_rounded,
                        color: HudColors.cyan, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.title,
                          style:
                              HudTextStyles.header(12, weight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.project.category,
                          style: HudTextStyles.mono(9, color: HudColors.cyan),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isLive
                          ? HudColors.green.withOpacity(0.1)
                          : HudColors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isLive
                            ? HudColors.green.withOpacity(0.4)
                            : HudColors.amber.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : 'OSS',
                      style: HudTextStyles.mono(
                        8,
                        color: isLive ? HudColors.green : HudColors.amber,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Standard Clean Description (No bullets)
              Text(
                widget.project.shortDesc,
                style: HudTextStyles.body(11, color: HudColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Key Highlights Bullets inside Card
              if (widget.project.metrics.isNotEmpty) ...[
                Text(
                  'KEY HIGHLIGHTS',
                  style: HudTextStyles.mono(8, color: HudColors.textMuted),
                ),
                const SizedBox(height: 6),
                ...widget.project.metrics.take(2).map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: HudColors.cyan,
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: [
                                BoxShadow(
                                  color: HudColors.cyan.withOpacity(0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m,
                              style: HudTextStyles.body(10, color: HudColors.textMain)
                                  .copyWith(height: 1.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
              ],

              // Tech stack chips restricted strictly to 2 rows
              SizedBox(
                height: 48,
                child: ClipRect(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: widget.project.stack
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: HudColors.cyan.withOpacity(0.05),
                                border: Border.all(
                                    color: HudColors.cyan.withOpacity(0.15)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t, style: HudTextStyles.mono(8)),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View details ↗',
                    style: HudTextStyles.mono(
                      9,
                      color: _hovered
                          ? HudColors.cyan
                          : HudColors.cyan.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cyberpunk HUD Project Modal ──────────────────────────────

class _ProjectModal extends StatelessWidget {
  final Project proj;
  final Future<void> Function(String) onLaunch;
  const _ProjectModal({required this.proj, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF030814),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: HudColors.cyan.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: HudColors.cyan.withOpacity(0.2),
              blurRadius: 50,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Modal Handle & Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: HudColors.cyan.withOpacity(0.04),
                border: Border(
                  bottom: BorderSide(color: HudColors.cyan.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: HudColors.cyan.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terminal_rounded,
                              size: 14, color: HudColors.cyan),
                          const SizedBox(width: 8),
                          Text(
                            'SYSTEM // PROJECT SPECIFICATION',
                            style: HudTextStyles.mono(9, color: HudColors.cyan),
                          ),
                        ],
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: HudColors.cyan.withOpacity(0.1),
                              border: Border.all(
                                  color: HudColors.cyan.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text('CLOSE', style: HudTextStyles.mono(9)),
                                const SizedBox(width: 4),
                                const Icon(Icons.close_rounded,
                                    size: 12, color: HudColors.cyan),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Modal Body
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(28),
                children: [
                  // Title Block
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlowText(
                              proj.title,
                              style: HudTextStyles.header(24,
                                  weight: FontWeight.w800),
                              glowColor: HudColors.cyan,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              proj.category.toUpperCase(),
                              style: HudTextStyles.mono(11,
                                  color: HudColors.cyan),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: proj.status == 'STORE RELEASE'
                              ? HudColors.green.withOpacity(0.1)
                              : HudColors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: proj.status == 'STORE RELEASE'
                                ? HudColors.green
                                : HudColors.amber,
                          ),
                        ),
                        child: Text(
                          proj.status,
                          style: HudTextStyles.mono(
                            9,
                            color: proj.status == 'STORE RELEASE'
                                ? HudColors.green
                                : HudColors.amber,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: HudColors.cyan.withOpacity(0.2)),
                  const SizedBox(height: 20),

                  // Overview
                  Text('OVERVIEW',
                      style: HudTextStyles.mono(10, color: HudColors.textMuted)),
                  const SizedBox(height: 8),
                  Text(
                    proj.longDesc,
                    style: HudTextStyles.body(13.5).copyWith(height: 1.7),
                  ),
                  const SizedBox(height: 24),

                  // Key Highlights Bullets inside Dialog
                  Text('KEY HIGHLIGHTS',
                      style: HudTextStyles.mono(10, color: HudColors.textMuted)),
                  const SizedBox(height: 12),
                  ...proj.metrics.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: HudColors.cyan,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: HudColors.cyan.withOpacity(0.8),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                m,
                                style: HudTextStyles.body(13)
                                    .copyWith(height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Technologies Section
                  Text('TECHNOLOGY STACK',
                      style: HudTextStyles.mono(10, color: HudColors.textMuted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: proj.stack
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: HudColors.cyan.withOpacity(0.08),
                                border: Border.all(
                                    color: HudColors.cyan.withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(t, style: HudTextStyles.mono(10)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Store & Deployment Actions
                  if (proj.playstore != null)
                    _storeBtn('Play Store ↗', proj.playstore!, HudColors.green),
                  if (proj.playstore != null && proj.appstore != null)
                    const SizedBox(height: 10),
                  if (proj.appstore != null)
                    _storeBtn('App Store ↗', proj.appstore!, HudColors.cyan),
                  if (proj.github != null) ...[
                    const SizedBox(height: 10),
                    _storeBtn('GitHub Repository ↗', proj.github!,
                        HudColors.magenta),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeBtn(String label, String url, Color color) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onLaunch(url),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.2),
              borderRadius: BorderRadius.circular(6),
              color: color.withOpacity(0.08),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: HudTextStyles.mono(11, color: color)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
}