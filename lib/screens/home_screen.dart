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
    final isWide = size.width > 700;
    final hPad = isWide ? 56.0 : 20.0;

    return Container(
      constraints: BoxConstraints(minHeight: size.height * 0.88),
      padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isWide ? _wideHero() : _narrowHero(),
        ),
      ),
    );
  }

  // ── Desktop two-column hero ──────────────────────────────────

  Widget _wideHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Text content
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusChip(),
              const SizedBox(height: 20),
              _heroName(),
              const SizedBox(height: 14),
              _typewriterRow(),
              const SizedBox(height: 18),
              _heroBio(),
              const SizedBox(height: 28),
              _statsRow(),
              const SizedBox(height: 32),
              _ctaRow(),
              const SizedBox(height: 24),
              _socialRow(),
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Right: Avatar card framing
        Expanded(
          flex: 4,
          child: Center(child: _avatarContainer(220)),
        ),
      ],
    );
  }

  // ── Mobile stacked hero ──────────────────────────────────────

  Widget _narrowHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatarContainer(150),
        const SizedBox(height: 24),
        _StatusChip(),
        const SizedBox(height: 18),
        _heroName(center: true),
        const SizedBox(height: 12),
        _typewriterRow(center: true),
        const SizedBox(height: 16),
        _heroBio(center: true),
        const SizedBox(height: 24),
        _statsRow(),
        const SizedBox(height: 24),
        _ctaRow(),
        const SizedBox(height: 20),
        _socialRow(center: true),
      ],
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _avatarContainer(double size) => ScrollAnimate(
        key: const ValueKey('home_avatar'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HudColors.cyan.withOpacity(0.3)),
            gradient: LinearGradient(
              colors: [HudColors.cyan.withOpacity(0.08), HudColors.magenta.withOpacity(0.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: HudColors.cyan.withOpacity(0.2), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [HudColors.cyan, HudColors.magenta],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/portfolio.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0A0A16),
                  child: const Icon(Icons.person, color: HudColors.cyan, size: 60),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _heroName({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_name'),
        child: Text(
          'ANIK SHAKYA',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: HudTextStyles.header(
            MediaQuery.of(context).size.width > 700 ? 40 : 28,
          ).copyWith(
            letterSpacing: 3.5,
            shadows: [
              const Shadow(color: HudColors.cyan, blurRadius: 15),
            ],
          ),
        ),
      );

  Widget _typewriterRow({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_type'),
        delay: const Duration(milliseconds: 100),
        child: Row(
          mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Text('> ', style: HudTextStyles.mono(16, color: HudColors.magenta)),
            Text(
              _typed,
              style: HudTextStyles.mono(16, color: HudColors.textMain),
            ),
            Text('_', style: HudTextStyles.mono(18, color: HudColors.cyan))
                .animate(onPlay: (c) => c.repeat())
                .fadeOut(duration: 500.ms, delay: 400.ms)
                .then()
                .fadeIn(duration: 500.ms),
          ],
        ),
      );

  Widget _heroBio({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_bio'),
        delay: const Duration(milliseconds: 150),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            'Professional Flutter Engineer & Mobile App Architect dedicated to crafting exceptional '
            'cross-platform experiences. With 4+ years of expertise engineering robust applications, '
            'I specialize in clean architecture, real-time backend synchronization, and high-performance UIs '
            'for international clients.',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HudTextStyles.body(14, color: HudColors.textMuted).copyWith(height: 1.7),
          ),
        ),
      );

  Widget _statsRow() => ScrollAnimate(
        key: const ValueKey('home_stats'),
        delay: const Duration(milliseconds: 180),
        child: Row(
          children: [
            _statChip('4+', 'Years Exp.'),
            const SizedBox(width: 12),
            _statChip('16+', 'Projects'),
            const SizedBox(width: 12),
            _statChip('100%', 'Satisfaction'),
          ],
        ),
      );

  Widget _statChip(String val, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: HudColors.magenta.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HudColors.magenta.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(val, style: HudTextStyles.header(18, color: HudColors.magenta)),
              const SizedBox(height: 2),
              Text(label, style: HudTextStyles.mono(9, color: HudColors.textMuted)),
            ],
          ),
        ),
      );

  Widget _ctaRow() => ScrollAnimate(
        key: const ValueKey('home_cta'),
        delay: const Duration(milliseconds: 220),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Only the primary contact CTA button remains here
            _HoverButton(
              onTap: widget.onContactTap,
              builder: (isHovered) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHovered
                        ? [HudColors.cyan, HudColors.cyan]
                        : [HudColors.cyan, const Color(0xFF00A8B5)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: HudColors.cyan.withOpacity(isHovered ? 0.5 : 0.25),
                      blurRadius: isHovered ? 20 : 12,
                    ),
                  ],
                ),
                child: Text(
                  'GET IN TOUCH',
                  style: HudTextStyles.mono(12, color: const Color(0xFF020208))
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _socialRow({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_socials'),
        delay: const Duration(milliseconds: 260),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: center ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _socialChip(Icons.code, 'GitHub', 'https://github.com/AnikShakya'),
            _socialChip(Icons.work_outline, 'LinkedIn', 'https://www.linkedin.com/in/anik-shakya-67141b192/'),
            _socialChip(Icons.camera_alt_outlined, 'Instagram', 'https://www.instagram.com/anik_shakya_'),
            _socialChip(Icons.description_outlined, 'Resume', 'https://github.com/AnikShakya'),
            _socialChip(Icons.phone_outlined, '+977 9863021878', 'tel:+9779863021878'),
            _socialChip(
              Icons.location_on_outlined,
              'Naghbahal, Lalitpur',
              'https://www.google.com/maps/search/?api=1&query=Naghbahal,+Lalitpur,+Nepal',
            ),
          ],
        ),
      );

  Widget _socialChip(IconData icon, String label, String url) => _HoverButton(
        onTap: () => _launch(url),
        builder: (isHovered) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: HudColors.cyan.withOpacity(isHovered ? 0.9 : 0.2),
            ),
            color: HudColors.cyan.withOpacity(isHovered ? 0.12 : 0.03),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: HudColors.cyan, size: 14),
              const SizedBox(width: 5),
              Text(label, style: HudTextStyles.mono(10, color: HudColors.textMain)),
            ],
          ),
        ),
      );
}

// ── Reusable Hover State Widget ──────────────────────────────────

class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool isHovered) builder;

  const _HoverButton({required this.onTap, required this.builder});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
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
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: widget.builder(_isHovered),
        ),
      ),
    );
  }
}

// ── Status chip ──────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: HudColors.green.withOpacity(0.08),
        border: Border.all(color: HudColors.green.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: HudColors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: HudColors.green, blurRadius: 6)],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.4, duration: 1000.ms),
          const SizedBox(width: 8),
          Text('Available for Work', style: HudTextStyles.mono(10, color: HudColors.green)),
        ],
      ),
    );
  }
}