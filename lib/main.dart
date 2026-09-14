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
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF020208),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeController = HudThemeController.instance;
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Anik Shakya — Flutter Developer',
        debugShowCheckedModeBanner: false,
        theme: hudTheme(dark: false),
        darkTheme: hudTheme(dark: true),
        themeMode: themeController.mode,
        home: const PortfolioRoot(),
      ),
    );
  }
}

class PortfolioRoot extends StatefulWidget {
  const PortfolioRoot({super.key});
  @override
  State<PortfolioRoot> createState() => _PortfolioRootState();
}

class _PortfolioRootState extends State<PortfolioRoot> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const _sectionNames = [
    'ABOUT',
    'EXPERIENCE',
    'PROJECTS',
    'SKILLS',
    'CONTACT',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isWide
          ? null
          : _MobileDrawer(
              currentIndex: _currentIndex,
              sectionNames: _sectionNames,
              onTap: _scrollTo,
              onThemeToggle: HudThemeController.instance.toggle,
            ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
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
          // Main content
          if (isWide)
            Row(children: [
              HudNavRail(currentIndex: _currentIndex, onTap: _scrollTo),
              Expanded(child: _buildPages(isWide)),
            ])
          else
            _buildPages(isWide),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) => _TopBar(
                currentIndex: _currentIndex,
                sectionNames: _sectionNames,
                isWide: isWide,
                onMenuTap:
                    isWide ? null : () => Scaffold.of(context).openDrawer(),
                onThemeToggle: HudThemeController.instance.toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPages(bool isWide) {
    final topPad = MediaQuery.of(context).padding.top;
    const bottomPad = 24.0;

    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: [
        _page(
          HomeScreen(onContactTap: () => _scrollTo(4)),
          topPad: topPad + 48,
          bottomPad: 0,
        ),
        _page(
          const ExperienceScreen(),
          topPad: topPad + 24,
          bottomPad: 0,
          scrollable: false,
        ),
        _page(const ProjectsScreen(),
            topPad: topPad + 24, bottomPad: bottomPad),
        _page(const SkillsScreen(), topPad: topPad + 24, bottomPad: 0),
        _page(
          const ContactScreen(),
          topPad: topPad + 56,
          bottomPad: 0,
          // fullWidth: true,
          scrollable: false,
        ),
      ],
    );
  }

  Widget _page(
    Widget child, {
    required double topPad,
    required double bottomPad,
    bool scrollable = true,
    bool fullWidth = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - topPad - bottomPad;
        final minHeight = availableHeight > 0 ? availableHeight : 0.0;
        final content = Padding(
          padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: fullWidth
                ? SizedBox(
                    height: minHeight,
                    child: child,
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: child,
                    ),
                  ),
          ),
        );

        return scrollable
            ? SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: content,
              )
            : content;
      },
    );
  }
}

// ── Top Bar ─────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int currentIndex;
  final List<String> sectionNames;
  final bool isWide;
  final VoidCallback? onMenuTap;
  final VoidCallback onThemeToggle;
  const _TopBar(
      {required this.currentIndex,
      required this.sectionNames,
      required this.isWide,
      required this.onMenuTap,
      required this.onThemeToggle});

  static const _resumeDownloadUrl =
      'https://drive.google.com/uc?export=download&id=1DVXMgBsQ2_-sZ87uilSv-n76lRJsrCFP';

  Future<void> _downloadResume() async {
    final uri = Uri.parse(_resumeDownloadUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: isWide ? 16 : 16,
        right: 16,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEE020208), Color(0x00020208)],
        ),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            IconButton(
              onPressed: onMenuTap,
              tooltip: 'Open navigation',
              icon: const Icon(Icons.menu_rounded,
                  color: HudColors.cyan, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: onThemeToggle,
            tooltip: 'Toggle theme',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: HudColors.amber,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Text(
              'ANIK SHAKYA // PORTFOLIO',
              overflow: TextOverflow.ellipsis,
              style: HudTextStyles.mono(10).copyWith(
                shadows: [const Shadow(color: HudColors.cyan, blurRadius: 8)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Download resume',
            child: InkWell(
              onTap: _downloadResume,
              borderRadius: BorderRadius.circular(3),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 9 : 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: HudColors.magenta.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(3),
                  color: HudColors.magenta.withOpacity(0.08),
                ),
                child: isWide
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_rounded,
                              size: 14, color: HudColors.magenta),
                          const SizedBox(width: 5),
                          Text('RESUME',
                              style: HudTextStyles.mono(9,
                                  color: HudColors.magenta)),
                        ],
                      )
                    : const Icon(Icons.download_rounded,
                        size: 16, color: HudColors.magenta),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(3),
              color: HudColors.cyan.withOpacity(0.05),
            ),
            child:
                Text(sectionNames[currentIndex], style: HudTextStyles.mono(9)),
          ),
        ],
      ),
    );
  }
}

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

  static const _icons = [
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.grid_view_rounded,
    Icons.bolt_rounded,
    Icons.mail_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 286,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? HudColors.surface
          : HudColors.lightSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
              child: Row(
                children: [
                  const Icon(Icons.blur_on_rounded,
                      color: HudColors.cyan, size: 22),
                  const SizedBox(width: 10),
                  Text('NAVIGATION', style: HudTextStyles.header(14)),
                ],
              ),
            ),
            const Divider(color: HudColors.borderCyan, height: 1),
            const SizedBox(height: 12),
            ...List.generate(sectionNames.length, (index) {
              final isSelected = index == currentIndex;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    _icons[index],
                    color: isSelected ? HudColors.cyan : HudColors.textMuted,
                    size: 21,
                  ),
                  title: Text(
                    sectionNames[index],
                    style: HudTextStyles.mono(
                      11,
                      color: isSelected ? HudColors.cyan : HudColors.textMain,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: isSelected ? HudColors.cyan : Colors.transparent,
                    ),
                  ),
                  tileColor: isSelected
                      ? HudColors.cyan.withOpacity(0.1)
                      : Colors.transparent,
                  onTap: () {
                    Navigator.of(context).pop();
                    onTap(index);
                  },
                ),
              );
            }),
            const Spacer(),
            const Divider(color: HudColors.borderCyan, height: 1),
            ListTile(
              leading: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: HudColors.amber,
              ),
              title: Text(
                Theme.of(context).brightness == Brightness.dark
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
