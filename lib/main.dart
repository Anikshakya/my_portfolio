import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  List<Widget> get _screens => [
        HomeScreen(onContactTap: () => _navigateTo(4)),
        const ExperienceScreen(),
        const ProjectsScreen(),
        const SkillsScreen(),
        const ContactScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: HudColors.background,
      body: Stack(
        children: [
          // Animated star background
          const Positioned.fill(child: SpaceBackground()),

          // Top scan-line overlay (subtle HUD effect)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0A00F0FF), Colors.transparent, Color(0x0AFF007F)],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          if (isWide)
            // Tablet/Desktop: side nav rail + page view
            Row(
              children: [
                HudNavRail(currentIndex: _currentIndex, onTap: _navigateTo),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    physics: const BouncingScrollPhysics(),
                    children: _screens,
                  ),
                ),
              ],
            )
          else
            // Mobile: full width pages + bottom nav
            PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              physics: const BouncingScrollPhysics(),
              children: _screens,
            ),

          // Top HUD status bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HudTopBar(currentIndex: _currentIndex),
          ),

          // Mobile bottom nav bar
          if (!isWide)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MobileBottomNav(currentIndex: _currentIndex, onTap: _navigateTo),
            ),
        ],
      ),
    );
  }
}

class _HudTopBar extends StatelessWidget {
  final int currentIndex;
  const _HudTopBar({required this.currentIndex});

  static const _sectionNames = ['ABOUT ME', 'CAREER LOGS', 'PROJECTS', 'SKILLS MATRIX', 'CONTACT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE0020208), Color(0x00020208)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ANIK SHAKYA // PORTFOLIO',
              style: HudTextStyles.mono(10).copyWith(
                shadows: [const Shadow(color: HudColors.cyan, blurRadius: 8)],
              )),
          Text(_sectionNames[currentIndex], style: HudTextStyles.mono(10)),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _MobileBottomNav({required this.currentIndex, required this.onTap});

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
        bottom: MediaQuery.of(context).padding.bottom,
        top: 4,
      ),
      decoration: const BoxDecoration(
        color: Color(0xF0040A1A),
        border: Border(top: BorderSide(color: Color(0x3300F0FF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isActive ? HudColors.cyan.withOpacity(0.1) : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_items[i].$1,
                      color: isActive ? HudColors.cyan : HudColors.textMuted,
                      size: 22),
                  const SizedBox(height: 3),
                  Text(_items[i].$2,
                      style: HudTextStyles.mono(8,
                          color: isActive ? HudColors.cyan : HudColors.textMuted)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
