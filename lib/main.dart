import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/hud_theme.dart';
import 'widgets/space_background.dart';
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
    return MaterialApp(
      title: 'Anik Shakya — Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: hudTheme(),
      home: const PortfolioRoot(),
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
    return Scaffold(
      backgroundColor: HudColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: SpaceBackground()),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x0A00F0FF),
                      Colors.transparent,
                      Color(0x0AFF007F)
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
            child: _TopBar(
              currentIndex: _currentIndex,
              sectionNames: _sectionNames,
              isWide: isWide,
            ),
          ),
          // Mobile bottom nav
          if (!isWide)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomNav(currentIndex: _currentIndex, onTap: _scrollTo),
            ),
        ],
      ),
    );
  }

  Widget _buildPages(bool isWide) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = isWide ? 24.0 : 72.0;

    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: [
        _page(
          HomeScreen(onContactTap: () => _scrollTo(4)),
          topPad: topPad + 48,
          bottomPad: bottomPad,
        ),
        _page(
          const ExperienceScreen(),
          topPad: topPad + 24,
          bottomPad: bottomPad,
          scrollable: false,
        ),
        _page(const ProjectsScreen(),
            topPad: topPad + 24, bottomPad: bottomPad),
        _page(const SkillsScreen(), topPad: topPad + 24, bottomPad: bottomPad),
        _page(
          const ContactScreen(),
          topPad: 0,
          bottomPad: 0,
          fullWidth: true,
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
  const _TopBar(
      {required this.currentIndex,
      required this.sectionNames,
      required this.isWide});

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

// ── Mobile Bottom Nav ────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.person_outline_rounded, 'About'),
    (Icons.work_outline_rounded, 'Career'),
    (Icons.grid_view_rounded, 'Projects'),
    (Icons.bolt_rounded, 'Skills'),
    (Icons.mail_outline_rounded, 'Contact'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom, top: 4),
      decoration: const BoxDecoration(
        color: Color(0xF5030810),
        border: Border(top: BorderSide(color: Color(0x3300F0FF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: active
                    ? HudColors.cyan.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_items[i].$1,
                      color: active ? HudColors.cyan : HudColors.textMuted,
                      size: 20),
                  const SizedBox(height: 2),
                  Text(_items[i].$2,
                      style: HudTextStyles.mono(7,
                          color:
                              active ? HudColors.cyan : HudColors.textMuted)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
