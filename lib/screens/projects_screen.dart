import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
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

  // ─────────────────────────────────────────────────────────────────────────
  // PAGINATION
  // ─────────────────────────────────────────────────────────────────────────

  int _getItemsPerPage(bool isWide) => isWide ? 6 : 2;

  int _getPageCount(bool isWide) {
    final count = _getItemsPerPage(isWide);

    if (_displayedProjects.isEmpty) {
      return 0;
    }

    return (_displayedProjects.length / count).ceil();
  }

  List<Project> get _displayedProjects {
    return _showAll ? projects : projects.where((p) => p.isShowcase).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _projectsPageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LAUNCH URL
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROJECT DETAILS
  // ─────────────────────────────────────────────────────────────────────────

  void _showDetail(Project proj) {
    showDialog(
      context: context,
      builder: (_) => _ProjectDetailDialog(
        proj: proj,
        onLaunch: _launch,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAGE NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────

  void _goToPage(int page) {
    if (!_projectsPageController.hasClients) {
      return;
    }

    _projectsPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        final hPad = isWide ? 40.0 : 24.0;

        final displayed = _displayedProjects;

        final itemsPerPage = _getItemsPerPage(isWide);

        final pageCount = _getPageCount(isWide);

        final hasPreviousPage = _currentPage > 0;

        final hasNextPage = pageCount > 0 && _currentPage < pageCount - 1;

        // Two rows.
        final double dynamicExtent = isWide ? 242.0 : 250.0;

        final double dynamicCarouselHeight = (dynamicExtent * 2) + 56.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _pageHeader(isWide),

                  const SizedBox(height: 30),

                  // ───────────────────────────────────────────────────────
                  // FILTER BAR
                  // ───────────────────────────────────────────────────────

                  ScrollAnimate(
                    key: const ValueKey('proj_tabs'),
                    child: _ProjectFilterBar(
                      showAll: _showAll,
                      projectCount: displayed.length,
                      onShowcase: () => _selectTab(false),
                      onAllProjects: () => _selectTab(true),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ───────────────────────────────────────────────────────
                  // PROJECT CAROUSEL
                  // ───────────────────────────────────────────────────────

                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: dynamicCarouselHeight,
                        child: PageView.builder(
                          controller: _projectsPageController,
                          itemCount: pageCount == 0 ? 1 : pageCount,
                          onPageChanged: (page) {
                            if (!mounted) return;

                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemBuilder: (_, page) {
                            final start = page * itemsPerPage;

                            final end = (start + itemsPerPage)
                                .clamp(0, displayed.length);

                            final pageProjects = displayed.sublist(
                              start,
                              end,
                            );

                            return GridView.builder(
                              clipBehavior: Clip.none,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 3 : 1,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: dynamicExtent,
                              ),
                              itemCount: pageProjects.length,
                              itemBuilder: (_, i) {
                                return ScrollAnimate(
                                  key: ValueKey(
                                      'proj_card_${pageProjects[i].id}'),
                                  delay: Duration(milliseconds: i * 60),
                                  child: _ProjectCard(
                                    project: pageProjects[i],
                                    onTap: () => _showDetail(pageProjects[i]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // ───────────────────────────────────────────────────
                      // PREVIOUS
                      // ───────────────────────────────────────────────────

                      if (hasPreviousPage)
                        Positioned(
                          left: isWide ? -20 : 0,
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Previous projects',
                            onPressed: () {
                              _goToPage(_currentPage - 1);
                            },
                          ),
                        ),

                      // ───────────────────────────────────────────────────
                      // NEXT
                      // ───────────────────────────────────────────────────

                      if (hasNextPage)
                        Positioned(
                          right: isWide ? -20 : 0,
                          child: _HoverableCarouselArrow(
                            icon: Icons.arrow_forward_ios_rounded,
                            tooltip: 'More projects',
                            onPressed: () {
                              _goToPage(_currentPage + 1);
                            },
                          ),
                        ),
                    ],
                  ),

                  // ───────────────────────────────────────────────────────
                  // PAGE INDICATOR
                  // ───────────────────────────────────────────────────────

                  if (pageCount > 1) ...[
                    const SizedBox(height: 8),
                    _PageIndicator(
                      currentPage: _currentPage,
                      pageCount: pageCount,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT TAB
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // PAGE HEADER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _pageHeader(bool isWide) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? HudColors.textMain : const Color(0xFF151A1E);

    return ScrollAnimate(
      key: const ValueKey('projects_header'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'PROJECT ARCHIVE',
            style: HudTextStyles.mono(
              10,
              color: isDark ? HudColors.textMuted : const Color(0xFF68747C),
            ).copyWith(
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 6),

          // Keep the HUD glow in dark mode only.
          if (isDark)
            GlowText(
              'PROJECTS',
              style: HudTextStyles.header(
                isWide ? 36 : 24,
              ).copyWith(
                letterSpacing: 3.0,
                fontWeight: FontWeight.w300,
                color: primaryText,
              ),
              glowColor: HudColors.cyan,
            )
          else
            Text(
              'PROJECTS',
              style: HudTextStyles.header(
                isWide ? 36 : 24,
              ).copyWith(
                letterSpacing: 3.0,
                fontWeight: FontWeight.w300,
                color: primaryText,
              ),
            ),

          const SizedBox(height: 7),

          Text(
            '// ${_displayedProjects.length} PROJECTS RECORDED',
            style: HudTextStyles.mono(
              10,
              color: isDark ? HudColors.textMuted : const Color(0xFF68747C),
            ).copyWith(
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECT FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectFilterBar extends StatelessWidget {
  final bool showAll;
  final int projectCount;
  final VoidCallback onShowcase;
  final VoidCallback onAllProjects;

  const _ProjectFilterBar({
    required this.showAll,
    required this.projectCount,
    required this.onShowcase,
    required this.onAllProjects,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background = HudColors.selectionBarSurface;
    final Color border = HudColors.selectionBarBorder;

    final Color mutedText =
        isDark ? HudColors.textMuted : const Color(0xFF68747C);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          _HoverableTab(
            label: 'Showcase',
            active: !showAll,
            onTap: onShowcase,
          ),
          const SizedBox(width: 4),
          _HoverableTab(
            label: 'All Projects',
            active: showAll,
            onTap: onAllProjects,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: HudColors.cyan,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '$projectCount PROJECTS',
                  style: HudTextStyles.mono(
                    9,
                    color: mutedText,
                  ).copyWith(
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOVERABLE TAB
// ─────────────────────────────────────────────────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const Color activeBackground = HudColors.primary;
    final Color inactiveBackground = HudColors.inactiveChipSurface;

    final Color hoverBackground =
        isDark ? HudColors.hoverSurface : const Color(0xFFEDF2F4);

    final Color inactiveBorder = HudColors.inactiveChipBorder;

    final Color textColor = widget.active
        ? (isDark ? HudColors.onPrimary : Colors.white)
        : (isDark ? HudColors.textMain : const Color(0xFF3F474D));

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.active
                ? activeBackground
                : (_isHovered ? hoverBackground : inactiveBackground),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.active ? activeBackground : inactiveBorder,
            ),
            boxShadow: widget.active && !isDark
                ? [
                    BoxShadow(
                      color: HudColors.cyan.withValues(alpha:0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: HudTextStyles.mono(
              9.5,
              color: textColor,
            ).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAROUSEL ARROW
// ─────────────────────────────────────────────────────────────────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background = HudColors.elevatedSurface;

    final Color border = _isHovered
        ? HudColors.cyan.withValues(alpha:
            isDark ? 0.75 : 0.45,
          )
        : HudColors.cardBorder;

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = false;
        });
      },
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
                ? (Matrix4.identity()..scale(1.08))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: background,
              border: Border.all(
                color: border,
                width: _isHovered ? 1.3 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: isDark
                            ? HudColors.primary.withValues(alpha:0.18)
                            : HudColors.shadowColor,
                        blurRadius: isDark ? 18 : 14,
                        spreadRadius: isDark ? 1 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: HudColors.shadowColor,
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: HudColors.cyan,
                size: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _PageIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) {
          final active = index == currentPage;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? HudColors.cyan
                  : isDark
                      ? Colors.white.withValues(alpha:0.16)
                      : Colors.black.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  String? _imageForProject(String id) {
    return switch (id) {
      'goatus' => 'assets/images/goatus.png',
      'morinfo' => 'assets/images/morinfo.png',
      'sendai-portal' => 'assets/images/sendai-portal.png',
      'pecon' => 'assets/images/pecon.png',
      'trandz-vistaar' => 'assets/images/trandz.png',
      'mulyankan' => 'assets/images/mulyankan.png',
      'durgabhagawati' => 'assets/images/durgabhagawati.png',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLive = widget.project.status == 'STORE RELEASE';

    final image = _imageForProject(widget.project.id);

    // ─────────────────────────────────────────────────────────────────────
    // COLORS
    // ─────────────────────────────────────────────────────────────────────

    final Color cardBackground = HudColors.elevatedSurface;
    final Color hoveredBackground = HudColors.hoverSurface;
    final Color borderColor =
        _hovered ? HudColors.hoverBorder : HudColors.cardBorder;

    final Color primaryText =
        isDark ? HudColors.textMain : const Color(0xFF151A1E);

    final Color secondaryText =
        isDark ? HudColors.textMuted : const Color(0xFF69757D);

    final Color iconBackground = isDark
        ? HudColors.cyan.withValues(alpha:0.07)
        : HudColors.cyan.withValues(alpha:0.055);

    final Color iconBorder = isDark
        ? HudColors.cyan.withValues(alpha:0.18)
        : HudColors.cyan.withValues(alpha:0.14);

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _hovered = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: _hovered ? const Offset(0, -5) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hovered ? hoveredBackground : cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: HudColors.primary.withValues(alpha:0.2),
                        blurRadius: 18,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: HudColors.shadowColor,
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─────────────────────────────────────────────────────────
                // HEADER
                // ─────────────────────────────────────────────────────────

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Project image
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: iconBorder,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: image == null
                          ? const Icon(
                              Icons.apps_rounded,
                              color: HudColors.cyan,
                              size: 16,
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.apps_rounded,
                                  color: HudColors.cyan,
                                  size: 16,
                                );
                              },
                            ),
                    ),

                    const SizedBox(width: 10),

                    // Title / Category
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HudTextStyles.header(
                              12,
                              weight: FontWeight.w700,
                            ).copyWith(
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.project.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HudTextStyles.mono(
                              8.5,
                              color: HudColors.cyan,
                            ).copyWith(
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Status
                    Flexible(
                      flex: 0,
                      child: _ProjectStatusBadge(
                        isLive: isLive,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ─────────────────────────────────────────────────────────
                // DESCRIPTION
                // ─────────────────────────────────────────────────────────

                Text(
                  widget.project.shortDesc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HudTextStyles.body(
                    11,
                    color: secondaryText,
                  ).copyWith(
                    height: 1.35,
                  ),
                ),

                // const SizedBox(height: 10),

                // ─────────────────────────────────────────────────────────
                // KEY HIGHLIGHTS
                // ─────────────────────────────────────────────────────────

                if (widget.project.metrics.isNotEmpty) ...[
                  Text(
                    'KEY HIGHLIGHTS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HudTextStyles.mono(
                      8,
                      color: secondaryText,
                    ).copyWith(
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...widget.project.metrics.take(2).map(
                    (metric) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 5,
                              ),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: HudColors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                metric,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HudTextStyles.body(
                                  10,
                                  color: primaryText,
                                ).copyWith(
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],

                // ─────────────────────────────────────────────────────────
                // TECHNOLOGY STACK
                // ─────────────────────────────────────────────────────────

                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: widget.project.stack
                            .map(
                              (technology) => _ProjectTechChip(
                                label: technology,
                                isDark: isDark,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ─────────────────────────────────────────────────────────
                // VIEW DETAILS
                // ─────────────────────────────────────────────────────────

                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    style: HudTextStyles.mono(
                      9,
                      color: _hovered
                          ? HudColors.cyan
                          : HudColors.cyan.withValues(alpha:
                              isDark ? 0.45 : 0.55,
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'VIEW DETAILS',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(width: 4),
                        AnimatedSlide(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          offset: _hovered
                              ? const Offset(
                                  0.15,
                                  -0.05,
                                )
                              : Offset.zero,
                          child: const Text('↗'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECT STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectStatusBadge extends StatelessWidget {
  final bool isLive;

  const _ProjectStatusBadge({
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isLive ? HudColors.green : HudColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:
          isDark ? 0.08 : 0.065,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha:
            isDark ? 0.24 : 0.20,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isLive ? 'LIVE' : 'OSS',
            style: HudTextStyles.mono(
              7.5,
              color: color,
            ).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TECHNOLOGY CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectTechChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _ProjectTechChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color background =
        isDark ? Colors.white.withValues(alpha:0.035) : const Color(0xFFEEF2F4);

    final Color border = isDark
        ? Colors.white.withValues(alpha:0.08)
        : Colors.black.withValues(alpha:0.055);

    final Color text =
        isDark ? HudColors.textMain.withValues(alpha:0.72) : const Color(0xFF59656D);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: border,
        ),
      ),
      child: Text(
        label,
        style: HudTextStyles.mono(
          7.5,
          color: text,
        ).copyWith(
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROJECT DETAIL DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectDetailDialog extends StatelessWidget {
  final Project proj;
  final Future<void> Function(String) onLaunch;

  const _ProjectDetailDialog({
    required this.proj,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final isLive = proj.status == 'STORE RELEASE';

    const accent = HudColors.cyan;

    // ───────────────────────────────────────────────────────────────────────
    // THEME COLORS
    // ───────────────────────────────────────────────────────────────────────

    final Color dialogBackground =
        isDark ? const Color(0xE914171B) : const Color(0xF5F8FAFB);

    final Color headerBackground =
        isDark ? Colors.white.withValues(alpha:0.035) : accent.withValues(alpha:0.025);

    final Color primaryText =
        isDark ? const Color(0xFFF3F5F7) : const Color(0xFF151A1E);

    final Color secondaryText =
        isDark ? const Color(0xFF8C969F) : const Color(0xFF667078);

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha:0.13)
        : Colors.black.withValues(alpha:0.075);

    final Color dividerColor = isDark
        ? Colors.white.withValues(alpha:0.08)
        : Colors.black.withValues(alpha:0.065);

    final Color innerSurface = isDark
        ? Colors.white.withValues(alpha:0.025)
        : Colors.black.withValues(alpha:0.018);

    final List<BoxShadow> shadows = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.42),
              blurRadius: 42,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: accent.withValues(alpha:0.08),
              blurRadius: 35,
              spreadRadius: -10,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.13),
              blurRadius: 38,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha:0.045),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
          maxHeight: 780,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: dialogBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                ),
                boxShadow: shadows,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      18,
                      18,
                      18,
                    ),
                    decoration: BoxDecoration(
                      color: headerBackground,
                      border: Border(
                        bottom: BorderSide(
                          color: dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha:
                              isDark ? 0.09 : 0.055,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accent.withValues(alpha:
                                isDark ? 0.18 : 0.14,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.terminal_rounded,
                            size: 16,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PROJECT SPECIFICATION',
                                style: HudTextStyles.mono(
                                  10,
                                  color: accent,
                                ).copyWith(
                                  letterSpacing: 1.35,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'SYSTEM // DETAIL VIEW',
                                style: HudTextStyles.mono(
                                  8,
                                  color: secondaryText,
                                ).copyWith(
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha:0.045)
                                  : Colors.black.withValues(alpha:
                                      0.035,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 17,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        25,
                        24,
                        30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isDark)
                                      GlowText(
                                        proj.title,
                                        style: HudTextStyles.header(
                                          24,
                                          weight: FontWeight.w800,
                                        ).copyWith(
                                          color: primaryText,
                                        ),
                                        glowColor: accent,
                                      )
                                    else
                                      Text(
                                        proj.title,
                                        style: HudTextStyles.header(
                                          24,
                                          weight: FontWeight.w800,
                                        ).copyWith(
                                          color: primaryText,
                                        ),
                                      ),
                                    const SizedBox(height: 7),
                                    Text(
                                      proj.category.toUpperCase(),
                                      style: HudTextStyles.mono(
                                        9,
                                        color: accent,
                                      ).copyWith(
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _StatusBadge(
                                status: proj.status,
                                isLive: isLive,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Container(
                            height: 1,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accent.withValues(alpha:
                                    isDark ? 0.45 : 0.30,
                                  ),
                                  accent.withValues(alpha:
                                    isDark ? 0.10 : 0.06,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SectionLabel(
                            title: 'OVERVIEW',
                            accent: accent,
                            textColor: secondaryText,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            proj.longDesc,
                            style: HudTextStyles.body(
                              13,
                              color: primaryText,
                            ).copyWith(
                              height: 1.65,
                            ),
                          ),
                          if (proj.metrics.isNotEmpty) ...[
                            const SizedBox(height: 27),
                            _SectionLabel(
                              title: 'KEY HIGHLIGHTS',
                              accent: accent,
                              textColor: secondaryText,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: innerSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor,
                                ),
                              ),
                              child: Column(
                                children: [
                                  ...proj.metrics.asMap().entries.map(
                                    (entry) {
                                      final index = entry.key;

                                      final metric = entry.value;

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              index == proj.metrics.length - 1
                                                  ? 0
                                                  : 12,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: accent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Text(
                                                metric,
                                                style: HudTextStyles.body(
                                                  12.5,
                                                  color: primaryText,
                                                ).copyWith(
                                                  height: 1.45,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 27),
                          _SectionLabel(
                            title: 'TECHNOLOGY STACK',
                            accent: accent,
                            textColor: secondaryText,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: proj.stack.map(
                              (technology) {
                                return _TechChip(
                                  label: technology,
                                  accent: accent,
                                  isDark: isDark,
                                  textColor: primaryText,
                                );
                              },
                            ).toList(),
                          ),
                          if (proj.playstore != null ||
                              proj.appstore != null ||
                              proj.github != null) ...[
                            const SizedBox(height: 30),
                            _SectionLabel(
                              title: 'ACCESS POINTS',
                              accent: accent,
                              textColor: secondaryText,
                            ),
                            const SizedBox(height: 12),
                            if (proj.playstore != null) ...[
                              _StoreActionButton(
                                label: 'PLAY STORE',
                                subtitle: 'ANDROID APPLICATION',
                                icon: Icons.shop_rounded,
                                url: proj.playstore!,
                                color: HudColors.green,
                                onLaunch: onLaunch,
                              ),
                              const SizedBox(height: 9),
                            ],
                            if (proj.appstore != null) ...[
                              _StoreActionButton(
                                label: 'APP STORE',
                                subtitle: 'IOS APPLICATION',
                                icon: Icons.apple,
                                url: proj.appstore!,
                                color: HudColors.cyan,
                                onLaunch: onLaunch,
                              ),
                              const SizedBox(height: 9),
                            ],
                            if (proj.github != null)
                              _StoreActionButton(
                                label: 'GITHUB REPOSITORY',
                                subtitle: 'SOURCE CODE',
                                icon: Icons.code_rounded,
                                url: proj.github!,
                                color: HudColors.magenta,
                                onLaunch: onLaunch,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color accent;
  final Color textColor;

  const _SectionLabel({
    required this.title,
    required this.accent,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: HudTextStyles.mono(
            9,
            color: textColor,
          ).copyWith(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG STATUS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;

  const _StatusBadge({
    required this.status,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isLive ? HudColors.green : HudColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:
          isDark ? 0.09 : 0.065,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha:
            isDark ? 0.28 : 0.22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            status,
            style: HudTextStyles.mono(
              8.5,
              color: color,
            ).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG TECH CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _TechChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool isDark;
  final Color textColor;

  const _TechChip({
    required this.label,
    required this.accent,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color background =
        isDark ? Colors.white.withValues(alpha:0.045) : const Color(0xFFEEF2F4);

    final Color border = isDark
        ? Colors.white.withValues(alpha:0.10)
        : Colors.black.withValues(alpha:0.075);

    final Color text =
        isDark ? textColor.withValues(alpha:0.82) : const Color(0xFF3F474D);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: border,
        ),
      ),
      child: Text(
        label,
        style: HudTextStyles.mono(
          8.5,
          color: text,
        ).copyWith(
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE / GITHUB ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _StoreActionButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String url;
  final Color color;
  final Future<void> Function(String) onLaunch;

  const _StoreActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.url,
    required this.color,
    required this.onLaunch,
  });

  @override
  State<_StoreActionButton> createState() => _StoreActionButtonState();
}

class _StoreActionButtonState extends State<_StoreActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background = _isHovered
        ? widget.color.withValues(alpha:
            isDark ? 0.10 : 0.065,
          )
        : isDark
            ? Colors.white.withValues(alpha:0.035)
            : Colors.black.withValues(alpha:0.022);

    final Color border = _isHovered
        ? widget.color.withValues(alpha:
            isDark ? 0.35 : 0.28,
          )
        : isDark
            ? Colors.white.withValues(alpha:0.10)
            : Colors.black.withValues(alpha:0.075);

    final Color subtitleColor = isDark
        ? Colors.white.withValues(alpha:0.40)
        : Colors.black.withValues(alpha:0.42);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () => widget.onLaunch(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: border,
              width: _isHovered ? 1.2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha:
                        isDark ? 0.12 : 0.06,
                      ),
                      blurRadius: 18,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha:
                    _isHovered
                        ? 0.13
                        : isDark
                            ? 0.065
                            : 0.055,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 17,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: HudTextStyles.mono(
                        10,
                        color: widget.color,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: HudTextStyles.mono(
                        7.5,
                        color: subtitleColor,
                      ).copyWith(
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: _isHovered ? const Offset(0.12, 0) : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isHovered ? 1 : 0.55,
                  child: Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: widget.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
