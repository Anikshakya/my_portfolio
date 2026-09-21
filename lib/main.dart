import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme/hud_theme.dart';
import 'widgets/animated_background.dart';
import 'widgets/nav_rail.dart';

import 'screens/home_screen.dart';
import 'screens/experience_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/contact_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF020208),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PortfolioApp());
}

// ============================================================================
// APP
// ============================================================================

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = HudThemeController.instance;

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Anik Shakya',
          debugShowCheckedModeBanner: false,

          theme: hudTheme(dark: false),
          darkTheme: hudTheme(dark: true),

          themeMode: themeController.mode,

          home: const PortfolioRoot(),
        );
      },
    );
  }
}

// ============================================================================
// PORTFOLIO ROOT
// ============================================================================

class PortfolioRoot extends StatefulWidget {
  const PortfolioRoot({super.key});

  @override
  State<PortfolioRoot> createState() => _PortfolioRootState();
}

class _PortfolioRootState extends State<PortfolioRoot> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  int _currentIndex = 0;

  static const List<String> _sectionNames = [
    'ABOUT',
    'EXPERIENCE',
    'PROJECTS',
    'SKILLS',
    'CONTACT',
  ];

  List<GlobalKey> get _sectionKeys => [
        _homeKey,
        _experienceKey,
        _projectsKey,
        _skillsKey,
        _contactKey,
      ];

  // --------------------------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // --------------------------------------------------------------------------
  // SCROLL TRACKING
  // --------------------------------------------------------------------------

  void _handleScroll() {
    if (!_scrollController.hasClients || !mounted) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Section whose top is closest to this point becomes active.
    final targetY = viewportHeight * 0.35;

    int closestIndex = _currentIndex;
    double closestDistance = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;

      if (sectionContext == null) {
        continue;
      }

      final renderObject = sectionContext.findRenderObject();

      if (renderObject is! RenderBox) {
        continue;
      }

      final globalPosition = renderObject.localToGlobal(
        Offset.zero,
      );

      final distance = (globalPosition.dy - targetY).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != _currentIndex) {
      setState(() {
        _currentIndex = closestIndex;
      });
    }
  }

  // --------------------------------------------------------------------------
  // NAVIGATION
  // --------------------------------------------------------------------------

  void _scrollTo(int index) {
    if (index < 0 || index >= _sectionKeys.length) {
      return;
    }

    final targetContext = _sectionKeys[index].currentContext;

    if (targetContext == null) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(
        milliseconds: 700,
      ),
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
  }

  void _navigateFromDrawer(int index) {
    Navigator.of(context).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollTo(index);
    });
  }

  // --------------------------------------------------------------------------
  // SECTION WRAPPER
  // --------------------------------------------------------------------------

  Widget _section({
    required GlobalKey key,
    required Widget child,
    double topPadding = 72,
    double bottomPadding = 72,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: child,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ALL PORTFOLIO SECTIONS
  // --------------------------------------------------------------------------

  Widget _buildPortfolioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --------------------------------------------------------------------
        // HOME / ABOUT
        // --------------------------------------------------------------------

        _section(
          key: _homeKey,
          topPadding: 0,
          bottomPadding: 72,
          child: HomeScreen(
            onContactTap: () => _scrollTo(4),
          ),
        ),

        // --------------------------------------------------------------------
        // EXPERIENCE
        // --------------------------------------------------------------------

        _section(
          key: _experienceKey,
          topPadding: 0,
          bottomPadding: 72,
          child: const ExperienceScreen(),
        ),

        // --------------------------------------------------------------------
        // PROJECTS
        // --------------------------------------------------------------------

        _section(
          key: _projectsKey,
          topPadding: 0,
          bottomPadding: 72,
          child: const ProjectsScreen(),
        ),

        // --------------------------------------------------------------------
        // SKILLS
        // --------------------------------------------------------------------

        _section(
          key: _skillsKey,
          topPadding: 0,
          bottomPadding: 72,
          child: const SkillsScreen(),
        ),

        // --------------------------------------------------------------------
        // CONTACT
        // --------------------------------------------------------------------

        _section(
          key: _contactKey,
          topPadding: 0,
          bottomPadding: 48,
          child: const ContactScreen(),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final isWide = size.width > 700;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,

      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,

      // ----------------------------------------------------------------------
      // MOBILE DRAWER
      // ----------------------------------------------------------------------

      drawer: isWide
          ? null
          : _MobileDrawer(
              currentIndex: _currentIndex,
              sectionNames: _sectionNames,
              onTap: _navigateFromDrawer,
              onThemeToggle:
                  HudThemeController.instance.toggle,
            ),

      // ----------------------------------------------------------------------
      // BODY
      // ----------------------------------------------------------------------

      body: Stack(
        children: [
          // ------------------------------------------------------------------
          // ANIMATED BACKGROUND
          // ------------------------------------------------------------------

          const Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBackground(),
            ),
          ),

          // ------------------------------------------------------------------
          // THEME OVERLAY
          // ------------------------------------------------------------------

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isDark
                          ? const Color(0x0AD2BB6F)
                          : const Color(0x18B59A50),

                      Colors.transparent,

                      isDark
                          ? const Color(0x0A9A526D)
                          : const Color(0x129A526D),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // MAIN CONTENT
          // ------------------------------------------------------------------

          Positioned.fill(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: isWide ? 64 : 28,
                  left: isWide ? 88 : 0,
                  right: 0,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: isWide,
                  child: SingleChildScrollView(
                    controller: _scrollController,

                    // Important:
                    // No PageView.
                    // Trackpad / mouse wheel / touch scrolling all use
                    // the same vertical scrollable.
                    physics: const BouncingScrollPhysics(),

                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildPortfolioContent(),

                        SizedBox(
                          height: isWide ? 40 : 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // DESKTOP NAV RAIL
          // ------------------------------------------------------------------

          if (isWide)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                child: HudNavRail(
                  currentIndex: _currentIndex,
                  onTap: _scrollTo,
                ),
              ),
            ),

          // ------------------------------------------------------------------
          // TOP BAR
          // ------------------------------------------------------------------

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                return _TopBar(
                  currentIndex: _currentIndex,
                  sectionNames: _sectionNames,
                  isWide: isWide,
                  onMenuTap: isWide
                      ? null
                      : () {
                          _scaffoldKey.currentState
                              ?.openDrawer();
                        },
                  onThemeToggle:
                      HudThemeController.instance.toggle,
                );
              },
            ),
          ),

          // ------------------------------------------------------------------
          // MOBILE SECTION INDICATOR
          // ------------------------------------------------------------------

          if (!isWide)
            Positioned(
              right: 16,
              bottom: 18,
              child: _MobileSectionIndicator(
                currentIndex: _currentIndex,
                sectionName:
                    _sectionNames[_currentIndex],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class _TopBar extends StatefulWidget {
  final int currentIndex;
  final List<String> sectionNames;
  final bool isWide;
  final VoidCallback? onMenuTap;
  final VoidCallback onThemeToggle;

  const _TopBar({
    required this.currentIndex,
    required this.sectionNames,
    required this.isWide,
    required this.onMenuTap,
    required this.onThemeToggle,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool _isResumeHovered = false;
  bool _isWebHovered = false;

  static const _resumeDownloadUrl =
      'https://drive.google.com/uc?export=download&id=1DVXMgBsQ2_-sZ87uilSv-n76lRJsrCFP';

  static const _reactPortfolioUrl =
      'https://anikshakya.vercel.app';

  Future<void> _downloadResume() async {
    final uri = Uri.parse(_resumeDownloadUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openReactPortfolio() async {
    final uri = Uri.parse(_reactPortfolioUrl);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: widget.isWide ? 16 : 16,
        right: 16,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xEE020208),
            Color(0x00020208),
          ],
        ),
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------
          // MOBILE MENU
          // ---------------------------------------------------------------

          if (!widget.isWide) ...[
            IconButton(
              onPressed: widget.onMenuTap,
              tooltip: 'Open navigation',
              icon: const Icon(
                Icons.menu_rounded,
                color: HudColors.cyan,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // ---------------------------------------------------------------
          // THEME BUTTON
          // ---------------------------------------------------------------

          IconButton(
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle theme',
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: HudColors.amber,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          // ---------------------------------------------------------------
          // BRAND
          // ---------------------------------------------------------------

          Expanded(
            child: Text(
              'ANIK SHAKYA // PORTFOLIO',
              overflow: TextOverflow.ellipsis,
              style: HudTextStyles.mono(10).copyWith(
                shadows: const [
                  Shadow(
                    color: HudColors.cyan,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ---------------------------------------------------------------
          // REACT WEBSITE
          // ---------------------------------------------------------------

          Tooltip(
            message: 'View React Website',
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isWebHovered = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isWebHovered = false;
                });
              },
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _openReactPortfolio,
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),

                  padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.isWide ? 9 : 7,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HudColors.cyan.withValues(
                        alpha:
                            _isWebHovered ? 0.9 : 0.5,
                      ),
                    ),

                    borderRadius:
                        BorderRadius.circular(3),

                    color: HudColors.cyan.withValues(
                      alpha:
                          _isWebHovered ? 0.22 : 0.08,
                    ),

                    boxShadow: _isWebHovered
                        ? [
                            BoxShadow(
                              color:
                                  HudColors.cyan
                                      .withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),

                  child: widget.isWide
                      ? Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              size: 14,
                              color: HudColors.cyan,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'REACT WEBSITE',
                              style: HudTextStyles.mono(
                                9,
                                color: HudColors.cyan,
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.language_rounded,
                          size: 16,
                          color: HudColors.cyan,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ---------------------------------------------------------------
          // RESUME
          // ---------------------------------------------------------------

          Tooltip(
            message: 'Download resume',
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isResumeHovered = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isResumeHovered = false;
                });
              },
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _downloadResume,
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),

                  padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.isWide ? 11 : 8,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: HudColors.cyan.withValues(
                        alpha:
                            _isResumeHovered ? 0.9 : 0.5,
                      ),
                    ),

                    borderRadius:
                        BorderRadius.circular(3),

                    color: HudColors.cyan.withValues(
                      alpha:
                          _isResumeHovered ? 0.22 : 0.08,
                    ),

                    boxShadow: _isResumeHovered
                        ? [
                            BoxShadow(
                              color:
                                  HudColors.cyan
                                      .withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),

                  child: widget.isWide
                      ? Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.download_rounded,
                              size: 14,
                              color: HudColors.cyan,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'RESUME',
                              style: HudTextStyles.mono(
                                9,
                                color: HudColors.cyan,
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.download_rounded,
                          size: 16,
                          color: HudColors.cyan,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MOBILE DRAWER
// ============================================================================

class _MobileDrawer extends StatelessWidget {
  final int currentIndex;
  final List<String> sectionNames;
  final ValueChanged<int> onTap;
  final VoidCallback onThemeToggle;

  const _MobileDrawer({
    required this.currentIndex,
    required this.sectionNames,
    required this.onTap,
    required this.onThemeToggle,
  });

  static const List<IconData> _icons = [
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.grid_view_rounded,
    Icons.bolt_rounded,
    Icons.mail_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 286,

      backgroundColor: isDark
          ? HudColors.surface
          : HudColors.lightSurface,

      child: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            // -------------------------------------------------------------
            // DRAWER HEADER
            // -------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                16,
                20,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.blur_on_rounded,
                    color: HudColors.cyan,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'NAVIGATION',
                    style: HudTextStyles.header(14),
                  ),
                ],
              ),
            ),

            const Divider(
              color: HudColors.borderCyan,
              height: 1,
            ),

            const SizedBox(height: 12),

            // -------------------------------------------------------------
            // NAVIGATION ITEMS
            // -------------------------------------------------------------

            ...List.generate(
              sectionNames.length,
              (index) {
                final isSelected =
                    index == currentIndex;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: ListTile(
                    dense: true,

                    leading: Icon(
                      _icons[index],
                      color: isSelected
                          ? HudColors.cyan
                          : HudColors.textMuted,
                      size: 21,
                    ),

                    title: Text(
                      sectionNames[index],
                      style: HudTextStyles.mono(
                        11,
                        color: isSelected
                            ? HudColors.cyan
                            : HudColors.textMain,
                      ),
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5),
                      side: BorderSide(
                        color: isSelected
                            ? HudColors.cyan
                            : Colors.transparent,
                      ),
                    ),

                    tileColor: isSelected
                        ? HudColors.cyan.withValues(
                            alpha: 0.1,
                          )
                        : Colors.transparent,

                    onTap: () {
                      onTap(index);
                    },
                  ),
                );
              },
            ),

            const Spacer(),

            const Divider(
              color: HudColors.borderCyan,
              height: 1,
            ),

            // -------------------------------------------------------------
            // THEME SWITCH
            // -------------------------------------------------------------

            ListTile(
              leading: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: HudColors.amber,
              ),

              title: Text(
                isDark
                    ? 'LIGHT MODE'
                    : 'DARK MODE',
                style: HudTextStyles.mono(10),
              ),

              onTap: onThemeToggle,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MOBILE SECTION INDICATOR
// ============================================================================

class _MobileSectionIndicator extends StatelessWidget {
  final int currentIndex;
  final String sectionName;

  const _MobileSectionIndicator({
    required this.currentIndex,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,

      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: HudColors.surface.withValues(
          alpha: 0.92,
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: HudColors.cyan.withValues(
            alpha: 0.35,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: HudColors.cyan.withValues(
              alpha: 0.08,
            ),
            blurRadius: 14,
          ),
        ],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: HudColors.cyan,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            sectionName,
            style: HudTextStyles.mono(
              8,
              color: HudColors.textMain,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            '${currentIndex + 1}/5',
            style: HudTextStyles.mono(
              8,
              color: HudColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}