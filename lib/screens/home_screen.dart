import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onContactTap;
  const HomeScreen({super.key, required this.onContactTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _typedText = '';
  static const _fullText =
      'Hi, I am ANIK SHAKYA.\n\n> CLASS: Flutter Developer\n> FOCUS: High-Performance Cross-Platform Apps';
  Timer? _timer;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 22), (t) {
      if (_idx < _fullText.length) {
        setState(() => _typedText = _fullText.substring(0, ++_idx));
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _socialBtn(String label, String url) => GestureDetector(
        onTap: () => _launch(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: HudColors.cyan.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(5),
            color: HudColors.cyan.withOpacity(0.06),
          ),
          child: Text(label, style: HudTextStyles.mono(10)),
        ),
      );

  Widget _stat(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: HudColors.magenta.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(5),
            color: HudColors.magenta.withOpacity(0.07),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowText(value,
                  style: HudTextStyles.header(16, color: HudColors.magenta),
                  glowColor: HudColors.magenta),
              const SizedBox(height: 2),
              Text(label,
                  style: HudTextStyles.mono(8, color: HudColors.textMuted)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HudPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Telemetry bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROFILE OVERVIEW // ANIK SHAKYA',
                            style: HudTextStyles.mono(10)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: HudColors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child:
                              Text('ID: AS-9610', style: HudTextStyles.mono(9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Avatar + name row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [HudColors.cyan, HudColors.magenta],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: HudColors.cyan.withOpacity(0.4),
                                  blurRadius: 20),
                              BoxShadow(
                                  color: HudColors.magenta.withOpacity(0.3),
                                  blurRadius: 12),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/portfolio.jpeg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF0A0A16),
                                child: const Icon(Icons.person,
                                    color: HudColors.cyan, size: 40),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlowText('ANIK SHAKYA',
                                style: HudTextStyles.header(22),
                                glowColor: HudColors.cyan),
                            const SizedBox(height: 4),
                            Text('FLUTTER DEVELOPER',
                                style: HudTextStyles.mono(11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Typing terminal
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xD9020208),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: HudColors.cyan.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _typedText,
                              style: HudTextStyles.mono(11.5,
                                      color: HudColors.textMain)
                                  .copyWith(height: 1.6),
                            ),
                          ),
                          Text('_',
                                  style: HudTextStyles.mono(16).copyWith(
                                    shadows: [
                                      Shadow(
                                          color: HudColors.cyan, blurRadius: 8)
                                    ],
                                  ))
                              .animate(onPlay: (c) => c.repeat())
                              .fadeOut(duration: 500.ms, delay: 500.ms)
                              .then()
                              .fadeIn(duration: 500.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // About Me
                    GlowText('ABOUT ME',
                        style: HudTextStyles.header(13,
                            color: HudColors.magenta, weight: FontWeight.w600),
                        glowColor: HudColors.magenta),
                    const SizedBox(height: 8),
                    Text(
                      'Flutter Developer with 4+ years of experience building high-performance, cross-platform mobile and web applications for international clients. Proficient in Flutter, Dart, REST APIs, Firebase, native platform integration, responsive UI development, in-app subscriptions, deep linking, maps, and many more. Focused on delivering scalable, maintainable solutions with strong performance, usability, clean architecture, and code quality.',
                      style: HudTextStyles.body(13),
                    ),
                    const SizedBox(height: 10),
                    // Location chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: HudColors.cyan.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(4),
                        color: HudColors.cyan.withOpacity(0.06),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: HudColors.cyan, size: 13),
                          const SizedBox(width: 5),
                          Text('Naghbahal, Lalitpur, Nepal',
                              style: HudTextStyles.mono(10.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Stats row
                    Row(
                      children: [
                        _stat('+4 YRS', 'EXPERIENCE'),
                        const SizedBox(width: 8),
                        _stat('16+', 'PROJECTS'),
                        const SizedBox(width: 8),
                        _stat('100%', 'SATISFACTION'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08),
              const SizedBox(height: 14),
              // Social links panel
              HudPanel(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONNECT WITH ME', style: HudTextStyles.mono(10)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _socialBtn('+977 9863021878', 'tel:+9779863021878'),
                        _socialBtn('GITHUB', 'https://github.com/AnikShakya'),
                        _socialBtn('LINKEDIN',
                            'https://www.linkedin.com/in/anik-shakya-67141b192/'),
                        _socialBtn('INSTAGRAM',
                            'https://www.instagram.com/anik_shakya_'),
                        GestureDetector(
                          onTap: widget.onContactTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: HudColors.magenta),
                              borderRadius: BorderRadius.circular(5),
                              color: HudColors.magenta.withOpacity(0.08),
                            ),
                            child: Text('GET IN TOUCH ↗',
                                style: HudTextStyles.mono(10,
                                        color: HudColors.magenta)
                                    .copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
