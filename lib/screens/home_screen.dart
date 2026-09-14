import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/scroll_animate.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onContactTap;
  const HomeScreen({super.key, required this.onContactTap});
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
    _typeTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      final target = _roles[_roleIndex];
      setState(() {
        if (!_deleting) {
          if (_charIdx < target.length) {
            _charIdx++;
          } else {
            _typeTimer?.cancel();
            _cycleTimer = Timer(const Duration(milliseconds: 2000), () {
              _deleting = true;
              _startTyping();
            });
            return;
          }
        } else {
          if (_charIdx > 0) {
            _charIdx--;
          } else {
            _deleting = false;
            _roleIndex = (_roleIndex + 1) % _roles.length;
            _typeTimer?.cancel();
            _cycleTimer = Timer(const Duration(milliseconds: 300), _startTyping);
            return;
          }
        }
        _typed = target.substring(0, _charIdx);
      });
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cycleTimer?.cancel();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      constraints: BoxConstraints(minHeight: size.height * 0.85),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40.0 : 16.0, vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isWide ? _desktopLayout() : _mobileStackedLayout(),
        ),
      ),
    );
  }

  // ── Desktop Layout (3 Columns) ───────────────────────────────

  Widget _desktopLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _heroHeader(center: true),
        const SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('BIOGRAPHY'),
                  const SizedBox(height: 12),
                  _heroBio(),
                  const SizedBox(height: 24),
                  _sectionTitle('CONTACT'),
                  const SizedBox(height: 12),
                  _contactInfoColumn(),
                  const SizedBox(height: 24),
                  _sectionTitle('SERVICES'),
                  const SizedBox(height: 12),
                  _servicesColumn(),
                  const SizedBox(height: 24),
                  _sectionTitle('CONNECT'),
                  const SizedBox(height: 12),
                  _socialLinksRow(),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 4,
              child: Center(
                child: _capsuleAvatarContainer(width: 300, height: 420),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statItem('4+', 'YEARS OF EXPERIENCE', crossAlign: CrossAxisAlignment.end),
                  const SizedBox(height: 28),
                  _statItem('100%', 'CLIENTS SATISFACTION', crossAlign: CrossAxisAlignment.end),
                  const SizedBox(height: 28),
                  _statItem('3+', 'COUNTRIES (NP, JP, IN)', crossAlign: CrossAxisAlignment.end),
                  const SizedBox(height: 28),
                  _statItem('16+', 'PROJECTS DONE', crossAlign: CrossAxisAlignment.end),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mobile Stacked Layout (Single Screen Fit) ────────────────

  Widget _mobileStackedLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          _heroHeader(center: true),
          const SizedBox(height: 14),

          // Centered Capsule Avatar
          _capsuleAvatarContainer(width: 130, height: 185),
          const SizedBox(height: 16),

          // Bio Section
          _sectionTitle('BIOGRAPHY', center: true),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Building scalable digital products and crafting exceptional cross-platform experiences deployed across Nepal, India, and Japan.',
              textAlign: TextAlign.center,
              style: HudTextStyles.body(11, color: HudColors.textMuted).copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 14),

          // Contact Section
          _sectionTitle('CONTACT', center: true),
          const SizedBox(height: 4),
          _contactInfoColumn(center: true),
          const SizedBox(height: 14),

          // Socials Section
          _sectionTitle('CONNECT', center: true),
          const SizedBox(height: 8),
          _socialLinksRow(center: true),
          const SizedBox(height: 14),

          // Horizontal Stats Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.015),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: HudColors.cyan.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _compactStatItem('4+', 'EXP'),
                _compactStatItem('100%', 'SATISFACTION'),
                _compactStatItem('3+', 'COUNTRIES'),
                _compactStatItem('16+', 'PROJECTS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Section ──────────────────────────────────────────

  Widget _heroHeader({bool center = false}) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ScrollAnimate(
          key: const ValueKey('home_name'),
          child: Text(
            'ANIK SHAKYA',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HudTextStyles.header(isWide ? 42 : 26).copyWith(
              letterSpacing: 2.0,
              color: HudColors.textMain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _typewriterRow(center: center),
      ],
    );
  }

  Widget _typewriterRow({bool center = false}) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final fontSize = isWide ? 22 : 15;
    return ScrollAnimate(
      key: const ValueKey('home_type'),
      delay: const Duration(milliseconds: 100),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            _typed,
            style: HudTextStyles.header(fontSize.toDouble()).copyWith(color: HudColors.textMain),
          ),
          Text('_', style: HudTextStyles.header(fontSize.toDouble(), color: HudColors.cyan))
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 500.ms, delay: 400.ms)
              .then()
              .fadeIn(duration: 500.ms),
        ],
      ),
    );
  }

  // ── Sub-components & Builders ────────────────────────────────

  Widget _sectionTitle(String title, {bool center = false}) {
    return Text(
      title,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: HudTextStyles.mono(10, color: HudColors.textMuted).copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _capsuleAvatarContainer({required double width, required double height}) {
    return ScrollAnimate(
      key: const ValueKey('home_avatar'),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width / 2),
          border: Border.all(color: HudColors.cyan.withOpacity(0.15)),
          color: Colors.white.withOpacity(0.02),
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width / 2 - 4),
          child: Image.asset(
            'assets/images/portfolio.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0A0A16),
              child: const Icon(Icons.person, color: HudColors.cyan, size: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroBio() => ScrollAnimate(
        key: const ValueKey('home_bio'),
        delay: const Duration(milliseconds: 150),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Building scalable digital products and crafting exceptional '
            'cross-platform experiences deployed across Nepal, India, and Japan. '
            'Specialized in clean architecture and high-performance UIs.',
            style: HudTextStyles.body(13, color: HudColors.textMuted).copyWith(height: 1.6),
          ),
        ),
      );

  Widget _contactInfoColumn({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_contact_info'),
        delay: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _textLink('Naghbahal, Lalitpur', 'https://www.google.com/maps/search/?api=1&query=Naghbahal,+Lalitpur,+Nepal'),
            const SizedBox(height: 4),
            _textLink('anikshakya@gmail.com', 'mailto:anikshakya@gmail.com'),
            const SizedBox(height: 4),
            _textLink('+977 9863021878', 'tel:+9779863021878'),
          ],
        ),
      );

  Widget _servicesColumn() => ScrollAnimate(
        key: const ValueKey('home_services'),
        delay: const Duration(milliseconds: 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Website Design', style: HudTextStyles.body(13, color: HudColors.textMain)),
            const SizedBox(height: 4),
            Text('Mobile Application Design', style: HudTextStyles.body(13, color: HudColors.textMain)),
            const SizedBox(height: 4),
            Text('Cross-Platform Architecture', style: HudTextStyles.body(13, color: HudColors.textMain)),
          ],
        ),
      );

  Widget _socialLinksRow({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_socials'),
        delay: const Duration(milliseconds: 300),
        child: Wrap(
          alignment: center ? WrapAlignment.center : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: [
            _socialChip(Icons.code, 'GitHub', 'https://github.com/AnikShakya'),
            _socialChip(Icons.work_outline, 'LinkedIn', 'https://www.linkedin.com/in/anik-shakya-67141b192/'),
            _socialChip(Icons.camera_alt_outlined, 'Instagram', 'https://www.instagram.com/anik_shakya_'),
            _socialChip(Icons.description_outlined, 'Resume', 'https://github.com/AnikShakya'),
            _socialChip(Icons.phone_outlined, '+977 9863021878', 'tel:+9779863021878'),
          ],
        ),
      );

  Widget _socialChip(IconData icon, String label, String url) {
    return _SocialChip(icon: icon, label: label, url: url);
  }

  Widget _textLink(String text, String url) {
    return InkWell(
      onTap: () => _launch(url),
      child: Text(
        text,
        style: HudTextStyles.body(11, color: HudColors.textMain),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statItem(String value, String label, {CrossAxisAlignment crossAlign = CrossAxisAlignment.start}) {
    return ScrollAnimate(
      key: ValueKey('stat_$label'),
      child: Column(
        crossAxisAlignment: crossAlign,
        children: [
          Text(
            value,
            style: HudTextStyles.header(36).copyWith(
              color: HudColors.textMain,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: HudTextStyles.mono(9, color: HudColors.textMuted).copyWith(
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: HudTextStyles.header(14).copyWith(
            color: HudColors.textMain,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: HudTextStyles.mono(8, color: HudColors.textMuted).copyWith(
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Interactive Hoverable Social Chip Widget with Icons ────────

class _SocialChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialChip({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: _isHovered ? HudColors.cyan.withOpacity(0.15) : Colors.white.withOpacity(0.02),
            border: Border.all(
              color: _isHovered ? HudColors.cyan : HudColors.cyan.withOpacity(0.25),
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: HudColors.cyan.withOpacity(0.2),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: _isHovered ? HudColors.cyan : HudColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: HudTextStyles.mono(
                  9.5,
                  color: _isHovered ? HudColors.cyan : HudColors.textMain,
                ).copyWith(letterSpacing: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}