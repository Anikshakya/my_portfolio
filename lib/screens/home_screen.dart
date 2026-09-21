import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/hud_theme.dart';
import '../widgets/scroll_animate.dart';

enum ScreenSize { mobile, tablet, desktop }

class HomeScreen extends StatefulWidget {
  final VoidCallback onContactTap;

  const HomeScreen({
    super.key,
    required this.onContactTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _typed = '';

  static const _roles = [
    'Flutter Developer',
    'Cross-Platform Engineer',
    'Mobile App Architect',
  ];

  int _roleIndex = 0;
  Timer? _typeTimer;
  Timer? _cycleTimer;
  int _charIdx = 0;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _typeTimer?.cancel();

    _typeTimer = Timer.periodic(
      const Duration(milliseconds: 60),
      (_) {
        if (!mounted) return;

        final target = _roles[_roleIndex];

        setState(() {
          if (!_deleting) {
            if (_charIdx < target.length) {
              _charIdx++;
              _typed = target.substring(0, _charIdx);
            } else {
              _typeTimer?.cancel();
              _cycleTimer = Timer(
                const Duration(milliseconds: 2000),
                () {
                  if (!mounted) return;
                  _deleting = true;
                  _startTyping();
                },
              );
            }
          } else {
            if (_charIdx > 0) {
              _charIdx--;
              _typed = target.substring(0, _charIdx);
            } else {
              _deleting = false;
              _roleIndex = (_roleIndex + 1) % _roles.length;
              _typeTimer?.cancel();
              _cycleTimer = Timer(
                const Duration(milliseconds: 300),
                () {
                  if (mounted) _startTyping();
                },
              );
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cycleTimer?.cancel();
    super.dispose();
  }

  ScreenSize _getScreenSize(double width) {
    if (width >= 1024) return ScreenSize.desktop;
    if (width >= 650) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenSize(constraints.maxWidth);
        final double hPadding = screenType == ScreenSize.desktop
            ? 60.0
            : (screenType == ScreenSize.tablet ? 40.0 : 20.0);

        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: size.height * 0.85),
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: 40.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: screenType == ScreenSize.desktop
                    ? _desktopLayout(screenType, constraints.maxWidth)
                    : _mobileStackedLayout(screenType, constraints.maxWidth),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DESKTOP LAYOUT (Split Screen with Floating Visuals)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _desktopLayout(ScreenSize screenType, double maxWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT COLUMN: Typography & Actions
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _greetingBadge(),
              const SizedBox(height: 24),
              _heroHeader(screenType: screenType),
              const SizedBox(height: 24),
              _heroBio(screenType: screenType),
              const SizedBox(height: 40),
              _actionButtonsRow(),
              const SizedBox(height: 48),
              _socialLinksRow(),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // RIGHT COLUMN: Visuals & Floating Stats
        Expanded(
          flex: 5,
          child: _floatingVisualsHero(screenType, maxWidth),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE / TABLET LAYOUT (Vertical Flow)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _mobileStackedLayout(ScreenSize screenType, double maxWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _greetingBadge(center: true),
        const SizedBox(height: 20),
        _heroHeader(screenType: screenType, center: true),
        const SizedBox(height: 32),

        // Visuals centered
        _floatingVisualsHero(screenType, maxWidth),

        const SizedBox(height: 40),
        _heroBio(screenType: screenType, center: true),
        const SizedBox(height: 32),
        _actionButtonsRow(center: true),
        const SizedBox(height: 40),
        _socialLinksRow(center: true),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPONENTS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _greetingBadge({bool center = false}) {
    return ScrollAnimate(
      key: const ValueKey('home_greeting'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: HudColors.cyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HudColors.cyan.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.waving_hand_rounded, size: 16, color: HudColors.cyan),
            const SizedBox(width: 8),
            Text(
              "HELLO, I'M",
              style: HudTextStyles.mono(11, color: HudColors.cyan)
                  .copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroHeader({required ScreenSize screenType, bool center = false}) {
    final double titleSize = screenType == ScreenSize.desktop
        ? 64
        : (screenType == ScreenSize.tablet ? 52 : 36);

    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ScrollAnimate(
          key: const ValueKey('home_name'),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'ANIK SHAKYA',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HudTextStyles.header(titleSize).copyWith(
              letterSpacing: 2.0,
              height: 1.1,
              color: HudColors.textMain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _typewriterRow(screenType: screenType, center: center),
      ],
    );
  }

  Widget _typewriterRow({required ScreenSize screenType, bool center = false}) {
    final fontSize = screenType == ScreenSize.desktop
        ? 28.0
        : (screenType == ScreenSize.tablet ? 24.0 : 18.0);

    return ScrollAnimate(
      key: const ValueKey('home_type'),
      delay: const Duration(milliseconds: 150),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            _typed,
            style: HudTextStyles.header(fontSize).copyWith(
              color: HudColors.cyan,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            '_',
            style: HudTextStyles.header(fontSize, color: HudColors.cyan),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeOut(duration: 500.ms, delay: 400.ms)
              .then()
              .fadeIn(duration: 500.ms),
        ],
      ),
    );
  }

  Widget _heroBio({required ScreenSize screenType, bool center = false}) {
    final double paddingH = screenType == ScreenSize.mobile ? 10.0 : 0.0;

    return ScrollAnimate(
      key: const ValueKey('home_bio'),
      delay: const Duration(milliseconds: 200),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: center ? 600 : 520),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingH),
          child: Text(
            'I engineer high-performance cross-platform applications with clean architecture. '
            'Delivering scalable digital solutions deployed across Nepal, India, and Japan.',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HudTextStyles.body(15, color: HudColors.textMuted).copyWith(
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION BUTTONS (CTAs)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _actionButtonsRow({bool center = false}) {
    return ScrollAnimate(
      key: const ValueKey('home_actions'),
      delay: const Duration(milliseconds: 250),
      child: Wrap(
        alignment: center ? WrapAlignment.center : WrapAlignment.start,
        spacing: 16,
        runSpacing: 16,
        children: [
          _PrimaryButton(
            text: "Let's Talk",
            icon: Icons.chat_bubble_outline,
            onTap: widget.onContactTap,
          ),
          _SecondaryButton(
            text: "View Resume",
            icon: Icons.download_rounded,
            onTap: () async{
              var downloadUrl ='https://drive.google.com/uc?export=download&id=1DVXMgBsQ2_-sZ87uilSv-n76lRJsrCFP';
              final uri = Uri.parse(downloadUrl);

              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPATIAL VISUALS (Avatar + Floating Stats)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _floatingVisualsHero(ScreenSize screenType, double maxWidth) {
    double avatarWidth;
    double avatarHeight;
    double statScale = 1.0;

    switch (screenType) {
      case ScreenSize.desktop:
        avatarWidth = 340.0;
        avatarHeight = 440.0;
        break;
      case ScreenSize.tablet:
        avatarWidth = 300.0;
        avatarHeight = 380.0;
        break;
      case ScreenSize.mobile:
        avatarWidth = (maxWidth * 0.6).clamp(200.0, 260.0);
        avatarHeight = avatarWidth * 1.3;
        statScale = avatarWidth < 240 ? 0.85 : 1.0;
        break;
    }

    final bool isWide = screenType == ScreenSize.desktop;

    return ScrollAnimate(
      key: const ValueKey('home_visuals'),
      delay: const Duration(milliseconds: 300),
      child: SizedBox(
        width: avatarWidth + (isWide ? 100 : 40),
        height: avatarHeight + (isWide ? 80 : 60),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient Glow behind avatar
            Container(
              width: avatarWidth * 0.8,
              height: avatarHeight * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: HudColors.cyan.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),

            // Main Avatar
            Container(
              width: avatarWidth,
              height: avatarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: HudColors.cyan.withValues(alpha: 0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/images/portfolio.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: HudColors.elevatedSurface),
                ),
              ),
            ),

            // Floating Stat 1 (Top Right)
            Positioned(
              top: isWide ? 20 : 0,
              right: isWide ? -40 : -10,
              child: Transform.scale(
                scale: statScale,
                child: const _GlassStatCard(
                  value: '4+',
                  label: 'Years Exp.',
                  icon: Icons.timer_outlined,
                ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
              ),
            ),

            // Floating Stat 2 (Bottom Left)
            Positioned(
              bottom: isWide ? 40 : 20,
              left: isWide ? -60 : -10,
              child: Transform.scale(
                scale: statScale,
                child: const _GlassStatCard(
                  value: '16+',
                  label: 'Projects',
                  icon: Icons.code_rounded,
                ).animate().fade(delay: 600.ms).slideY(begin: -0.2, end: 0),
              ),
            ),

            // Floating Stat 3 (Bottom Right)
            Positioned(
              bottom: isWide ? -20 : -15,
              right: isWide ? 20 : 0,
              child: Transform.scale(
                scale: statScale,
                child: const _GlassStatCard(
                  value: '100%',
                  label: 'Client Satisfaction',
                  icon: Icons.star_outline_rounded,
                ).animate().fade(delay: 700.ms).slideX(begin: -0.2, end: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCIAL LINKS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _socialLinksRow({bool center = false}) {
    return ScrollAnimate(
      key: const ValueKey('home_socials'),
      delay: const Duration(milliseconds: 350),
      child: Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            "CONNECT",
            style: HudTextStyles.mono(10, color: HudColors.textMuted)
                .copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: center ? WrapAlignment.center : WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: const [
              _SocialIconBtn(icon: Icons.code, url: 'https://github.com/AnikShakya', tooltip: 'GitHub'),
              _SocialIconBtn(icon: Icons.work_outline, url: 'https://www.linkedin.com/in/anik-shakya-67141b192/', tooltip: 'LinkedIn'),
              _SocialIconBtn(icon: Icons.camera_alt_outlined, url: 'https://www.instagram.com/anik_shakya_', tooltip: 'Instagram'),
              _SocialIconBtn(icon: Icons.email_outlined, url: 'mailto:anikshakya@gmail.com', tooltip: 'Email'),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CUSTOM UI WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _GlassStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _GlassStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: HudColors.elevatedSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HudColors.cyan.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HudColors.cyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: HudColors.cyan, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: HudTextStyles.header(20).copyWith(color: HudColors.textMain, height: 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: HudTextStyles.mono(10, color: HudColors.textMuted).copyWith(letterSpacing: 0.5),
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

class _PrimaryButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({required this.text, required this.icon, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? HudColors.cyan.withValues(alpha: 0.9) : HudColors.cyan,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [BoxShadow(color: HudColors.cyan.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: HudTextStyles.body(14, color: Colors.black).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({required this.text, required this.icon, required this.onTap});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? HudColors.cyan.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HudColors.cyan, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: HudTextStyles.body(14, color: HudColors.cyan).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18, color: HudColors.cyan),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconBtn extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;

  const _SocialIconBtn({required this.icon, required this.url, required this.tooltip});

  @override
  State<_SocialIconBtn> createState() => _SocialIconBtnState();
}

class _SocialIconBtnState extends State<_SocialIconBtn> {
  bool _isHovered = false;

  Future<void> _launch() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      textStyle: HudTextStyles.mono(10, color: Colors.black),
      decoration: BoxDecoration(color: HudColors.cyan, borderRadius: BorderRadius.circular(4)),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _launch,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isHovered ? HudColors.cyan.withValues(alpha: 0.15) : HudColors.elevatedSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovered ? HudColors.cyan.withValues(alpha: 0.5) : HudColors.inactiveChipBorder,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _isHovered ? HudColors.cyan : HudColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}