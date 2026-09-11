import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _status = 'READY'; // READY, SENDING, SENT

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _status = 'SENDING');
    await Future.delayed(const Duration(milliseconds: 600));
    final subject =
        Uri.encodeComponent('Portfolio Inquiry from ${_nameCtrl.text}');
    final body = Uri.encodeComponent(
        'Hi Anik,\n\nI\'m reaching out through your portfolio.\n\n${_messageCtrl.text}\n\nBest regards,\n${_nameCtrl.text}\n${_emailCtrl.text}');
    final mailtoUrl = 'mailto:aniklinkin@gmail.com?subject=$subject&body=$body';
    await _launch(mailtoUrl);
    setState(() => _status = 'SENT');
  }

  void _reset() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();
    setState(() => _status = 'READY');
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 10,
                color: HudColors.cyan,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: HudTextStyles.mono(10).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: HudTextStyles.body(13),
            cursorColor: HudColors.cyan,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: HudColors.cyan.withOpacity(0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: HudColors.cyan, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    BorderSide(color: HudColors.magenta.withOpacity(0.6)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: HudColors.magenta),
              ),
              filled: true,
              fillColor: const Color(0x99020208),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final hPad = isWide ? 56.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Main Content Container ──────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Unified HUD Header ──────────────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0x99020208),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: HudColors.cyan.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: HudColors.cyan.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                            color: HudColors.cyan
                                                .withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        'SECTION // 05',
                                        style: HudTextStyles.mono(9,
                                            color: HudColors.cyan),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'COMMUNICATION LINK',
                                      style: HudTextStyles.mono(9,
                                          color: HudColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                GlowText(
                                  'GET IN TOUCH',
                                  style: HudTextStyles.header(
                                    22,
                                    color: HudColors.magenta,
                                  ),
                                  glowColor: HudColors.magenta,
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: HudTextStyles.body(
                                      13,
                                      color: HudColors.textMuted,
                                    ).copyWith(height: 1.5),
                                    children: const [
                                      TextSpan(
                                        text:
                                            'Have a project in mind or want to collaborate? Direct transmission open via form below or email to ',
                                      ),
                                      TextSpan(
                                        text: 'aniklinkin@gmail.com',
                                        style: TextStyle(
                                          color: HudColors.cyan,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: HudColors.cyan,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ── Contact Quick Cards ────────────────────────────────
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 4 : 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: isWide ? 2.6 : 2.6,
                            children: [
                              _HoverContactCard(
                                label: 'PHONE',
                                value: '+977 9863021878',
                                url: 'tel:+9779863021878',
                                icon: Icons.phone_outlined,
                                onTap: () => _launch('tel:+9779863021878'),
                              ),
                              _HoverContactCard(
                                label: 'EMAIL',
                                value: 'aniklinkin@gmail.com',
                                url: 'mailto:aniklinkin@gmail.com',
                                icon: Icons.email_outlined,
                                onTap: () =>
                                    _launch('mailto:aniklinkin@gmail.com'),
                              ),
                              _HoverContactCard(
                                label: 'LINKEDIN',
                                value: 'Anik Shakya',
                                url:
                                    'https://www.linkedin.com/in/anik-shakya-67141b192/',
                                icon: Icons.work_outline,
                                onTap: () => _launch(
                                    'https://www.linkedin.com/in/anik-shakya-67141b192/'),
                              ),
                              _HoverContactCard(
                                label: 'INSTAGRAM',
                                value: '@anik_shakya_',
                                url: 'https://www.instagram.com/anik_shakya_',
                                icon: Icons.camera_alt_outlined,
                                onTap: () => _launch(
                                    'https://www.instagram.com/anik_shakya_'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // ── Scaled & Compact Form Panel ───────────────────────────────────
                          HudPanel(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: _status == 'READY'
                                  ? Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _inputField(
                                            label: 'YOUR NAME',
                                            controller: _nameCtrl,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 14),
                                          _inputField(
                                            label: 'YOUR EMAIL ADDRESS',
                                            controller: _emailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return 'Required';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Invalid email address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 14),
                                          _inputField(
                                            label: 'TRANSMISSION MESSAGE',
                                            controller: _messageCtrl,
                                            maxLines: 4,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 18),
                                          _HoverButton(
                                            label: 'TRANSMIT MESSAGE',
                                            color: HudColors.magenta,
                                            onTap: _submit,
                                          ),
                                        ],
                                      ),
                                    )
                                  : _status == 'SENDING'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 36),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const CircularProgressIndicator(
                                                    color: HudColors.cyan,
                                                    strokeWidth: 2),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'INITIALIZING TRANSMISSION...',
                                                  style: HudTextStyles.mono(12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 32),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 52,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: HudColors.green
                                                        .withOpacity(0.1),
                                                    border: Border.all(
                                                        color: HudColors.green,
                                                        width: 1.5),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: HudColors.green,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  'EMAIL CLIENT OPENED',
                                                  style: HudTextStyles.header(
                                                      15,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Message pre-filled for aniklinkin@gmail.com',
                                                  style: HudTextStyles.body(
                                                    12,
                                                    color: HudColors.textMuted,
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                _HoverButton(
                                                  label: 'SEND ANOTHER MESSAGE',
                                                  color: HudColors.cyan,
                                                  onTap: _reset,
                                                  isFullWidth: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Footer Section ──────────────────────────────────
        _footer(),
      ],
    );
  }

  Widget _footer() {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 58),
      decoration: const BoxDecoration(
        color: Color(0xD9020208),
        border: Border(top: BorderSide(color: Color(0x4D00F0FF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _footerBrandingColumn(),
                _footerContactColumn(),
                _footerSocialColumn(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _footerBrandingColumn(),
                const SizedBox(height: 20),
                _footerContactColumn(),
                const SizedBox(height: 20),
                _footerSocialColumn(),
              ],
            ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x14FFFFFF), height: 1),
          const SizedBox(height: 12),
          if (isWide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _footerCopyrightText(),
                _footerStatusText(),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _footerCopyrightText(),
                const SizedBox(height: 6),
                _footerStatusText(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _footerBrandingColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlowText(
            'ANIK SHAKYA',
            style: HudTextStyles.header(15),
            glowColor: HudColors.cyan,
          ),
          const SizedBox(height: 3),
          Text(
            'SENIOR FLUTTER & CROSS-PLATFORM DEVELOPER',
            style: HudTextStyles.mono(
              8,
              color: HudColors.cyan,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Naghbahal, Lalitpur, Nepal',
            style: HudTextStyles.mono(
              9,
              color: HudColors.textMuted,
            ),
          ),
        ],
      );

  Widget _footerContactColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIRECT CONTACT',
            style: HudTextStyles.mono(
              8,
              color: HudColors.cyan,
            ),
          ),
          const SizedBox(height: 5),
          _HoverTextLink(
            text: 'aniklinkin@gmail.com',
            onTap: () => _launch('mailto:aniklinkin@gmail.com'),
          ),
          const SizedBox(height: 3),
          _HoverTextLink(
            text: '+977 9863021878',
            onTap: () => _launch('tel:+9779863021878'),
          ),
        ],
      );

  Widget _footerSocialColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOCIAL NETWORKS',
            style: HudTextStyles.mono(
              8,
              color: HudColors.magenta,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HoverSocialBadge(
                label: 'GitHub',
                url: 'https://github.com/AnikShakya',
                color: HudColors.cyan,
                icon: Icons.code,
                onTap: () => _launch('https://github.com/AnikShakya'),
              ),
              _HoverSocialBadge(
                label: 'LinkedIn',
                url: 'https://www.linkedin.com/in/anik-shakya-67141b192/',
                color: HudColors.magenta,
                icon: Icons.work,
                onTap: () => _launch(
                    'https://www.linkedin.com/in/anik-shakya-67141b192/'),
              ),
              _HoverSocialBadge(
                label: 'Instagram',
                url: 'https://www.instagram.com/anik_shakya_',
                color: HudColors.amber,
                icon: Icons.camera_alt,
                onTap: () => _launch('https://www.instagram.com/anik_shakya_'),
              ),
            ],
          ),
        ],
      );

  Widget _footerCopyrightText() => Text(
        '© ${DateTime.now().year} ANIK SHAKYA // '
        '${DateTime.now().toString().substring(0, 16)} // ALL SYSTEMS OPERATIONAL',
        style: HudTextStyles.mono(
          8,
          color: HudColors.textMuted,
        ),
      );

  Widget _footerStatusText() => Text(
        '● SYSTEM STATUS: ONLINE',
        style: HudTextStyles.mono(
          8,
          color: HudColors.green,
        ),
      );
}

// ── ENHANCED HOVER HELPER WIDGETS ─────────────────────────────────────────────

class _HoverContactCard extends StatefulWidget {
  final String label;
  final String value;
  final String url;
  final IconData icon;
  final VoidCallback onTap;

  const _HoverContactCard({
    required this.label,
    required this.value,
    required this.url,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HoverContactCard> createState() => _HoverContactCardState();
}

class _HoverContactCardState extends State<_HoverContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? HudColors.cyan.withOpacity(0.08)
                : const Color(0x80020208),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color:
                  _isHovered ? HudColors.cyan : HudColors.cyan.withOpacity(0.2),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: HudColors.cyan.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: HudTextStyles.mono(
                      8,
                      color: _isHovered ? Colors.white : HudColors.cyan,
                    ),
                  ),
                  Icon(
                    widget.icon,
                    size: 12,
                    color: _isHovered ? HudColors.cyan : HudColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                widget.value,
                style: HudTextStyles.body(
                  11,
                  color: _isHovered ? HudColors.cyan : Colors.white,
                ).copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverSocialBadge extends StatefulWidget {
  final String label;
  final String url;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _HoverSocialBadge({
    required this.label,
    required this.url,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HoverSocialBadge> createState() => _HoverSocialBadgeState();
}

class _HoverSocialBadgeState extends State<_HoverSocialBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
                color:
                    _isHovered ? widget.color : widget.color.withOpacity(0.5),
                width: 1),
            borderRadius: BorderRadius.circular(4),
            color: _isHovered ? widget.color : widget.color.withOpacity(0.08),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 11,
                color: _isHovered ? Colors.black : widget.color,
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: HudTextStyles.mono(
                  9,
                  color: _isHovered ? Colors.black : widget.color,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 3),
              Text(
                '↗',
                style: TextStyle(
                  fontSize: 9,
                  color: _isHovered ? Colors.black : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _HoverButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isFullWidth = true,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 22),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            color: _isHovered ? widget.color : widget.color.withOpacity(0.08),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: HudTextStyles.mono(
              12,
              color: _isHovered ? Colors.black : widget.color,
            ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
        ),
      ),
    );
  }
}

class _HoverTextLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverTextLink({
    required this.text,
    required this.onTap,
  });

  @override
  State<_HoverTextLink> createState() => _HoverTextLinkState();
}

class _HoverTextLinkState extends State<_HoverTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: HudTextStyles.mono(
            10,
            color: _isHovered ? HudColors.cyan : Colors.white,
          ).copyWith(
            decoration:
                _isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
