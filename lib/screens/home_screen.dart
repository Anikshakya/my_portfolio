import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';
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
    final hPad = isWide ? 56.0 : 24.0;

    return Container(
      constraints: BoxConstraints(minHeight: size.height * 0.88),
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 80),
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
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusChip(),
              const SizedBox(height: 24),
              _heroName(),
              const SizedBox(height: 16),
              _typewriterRow(),
              const SizedBox(height: 20),
              _heroBio(),
              const SizedBox(height: 32),
              _statsRow(),
              const SizedBox(height: 36),
              _ctaRow(),
              const SizedBox(height: 28),
              _socialRow(),
            ],
          ),
        ),
        const SizedBox(width: 60),
        // Right: Avatar
        Expanded(
          flex: 4,
          child: Center(child: _avatar(200)),
        ),
      ],
    );
  }

  // ── Mobile stacked hero ──────────────────────────────────────

  Widget _narrowHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(120),
        const SizedBox(height: 28),
        _StatusChip(),
        const SizedBox(height: 20),
        _heroName(center: true),
        const SizedBox(height: 12),
        _typewriterRow(center: true),
        const SizedBox(height: 16),
        _heroBio(center: true),
        const SizedBox(height: 28),
        _statsRow(),
        const SizedBox(height: 28),
        _ctaRow(),
        const SizedBox(height: 22),
        _socialRow(center: true),
      ],
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _avatar(double size) => ScrollAnimate(
        key: const ValueKey('home_avatar'),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [HudColors.cyan, HudColors.magenta],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: HudColors.cyan.withOpacity(0.35), blurRadius: 40, spreadRadius: 2),
              BoxShadow(color: HudColors.magenta.withOpacity(0.2), blurRadius: 30),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipOval(
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
      );

  Widget _heroName({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_name'),
        child: Text(
          'ANIK SHAKYA',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: HudTextStyles.header(
            MediaQuery.of(context).size.width > 700 ? 42 : 30,
          ).copyWith(
            letterSpacing: 3,
            shadows: [
              const Shadow(color: HudColors.cyan, blurRadius: 20),
              const Shadow(color: HudColors.cyan, blurRadius: 40),
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
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Flutter Developer with 4+ years of experience building high-performance '
            'cross-platform mobile & web apps for international clients. '
            'Specializing in clean architecture, Firebase, REST APIs, native platform integration, and polished UI.',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: HudTextStyles.body(14.5, color: HudColors.textMuted).copyWith(height: 1.75),
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
            _statChip('2', 'Countries'),
          ],
        ),
      );

  Widget _statChip(String val, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: HudColors.magenta.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HudColors.magenta.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Text(val, style: HudTextStyles.header(20, color: HudColors.magenta)),
              const SizedBox(height: 4),
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
            // Primary CTA
            GestureDetector(
              onTap: widget.onContactTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [HudColors.cyan, Color(0xFF00A8B5)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: HudColors.cyan.withOpacity(0.35), blurRadius: 20)],
                ),
                child: Text(
                  'GET IN TOUCH',
                  style: HudTextStyles.mono(12, color: const Color(0xFF020208))
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Secondary CTA
            GestureDetector(
              onTap: () => _launch('https://github.com/AnikShakya'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: HudColors.cyan.withOpacity(0.5)),
                  color: HudColors.cyan.withOpacity(0.05),
                ),
                child: Text('VIEW GITHUB ↗', style: HudTextStyles.mono(12)),
              ),
            ),
          ],
        ),
      );

  Widget _socialRow({bool center = false}) => ScrollAnimate(
        key: const ValueKey('home_socials'),
        delay: const Duration(milliseconds: 260),
        child: Row(
          mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _iconLink(Icons.code, 'https://github.com/AnikShakya'),
            const SizedBox(width: 14),
            _iconLink(Icons.work_outline, 'https://www.linkedin.com/in/anik-shakya-67141b192/'),
            const SizedBox(width: 14),
            _iconLink(Icons.camera_alt_outlined, 'https://www.instagram.com/anik_shakya_'),
            const SizedBox(width: 14),
            _iconLink(Icons.phone_outlined, 'tel:+9779863021878'),
            const SizedBox(width: 20),
            Container(width: 1, height: 20, color: HudColors.textMuted.withOpacity(0.3)),
            const SizedBox(width: 20),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: HudColors.cyan, size: 13),
              const SizedBox(width: 5),
              Text('Lalitpur, Nepal', style: HudTextStyles.mono(10, color: HudColors.textMuted)),
            ]),
          ],
        ),
      );

  Widget _iconLink(IconData icon, String url) => GestureDetector(
        onTap: () => _launch(url),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: HudColors.cyan.withOpacity(0.2)),
            color: HudColors.cyan.withOpacity(0.04),
          ),
          child: Icon(icon, color: HudColors.cyan, size: 16),
        ),
      );
}

// ── Status chip ──────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HudColors.green.withOpacity(0.08),
        border: Border.all(color: HudColors.green.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: HudColors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: HudColors.green, blurRadius: 6)],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.3, duration: 1000.ms),
          const SizedBox(width: 8),
          Text('Available for Work', style: HudTextStyles.mono(10, color: HudColors.green)),
        ],
      ),
    );
  }
}
