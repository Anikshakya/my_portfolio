import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _status = 'SENDING');
    await Future.delayed(const Duration(milliseconds: 600));
    final subject = Uri.encodeComponent('Portfolio Inquiry from ${_nameCtrl.text}');
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
          Text(label,
              style: HudTextStyles.mono(10).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: HudTextStyles.body(13),
            cursorColor: HudColors.cyan,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: HudColors.cyan.withOpacity(0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: HudColors.cyan),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: HudColors.magenta.withOpacity(0.6)),
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    HudPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GET IN TOUCH // CONTACT', style: HudTextStyles.mono(10)),
                          const SizedBox(height: 6),
                          GlowText('GET IN TOUCH',
                              style: HudTextStyles.header(20, color: HudColors.magenta),
                              glowColor: HudColors.magenta),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: HudTextStyles.body(12.5, color: HudColors.textMuted),
                              children: const [
                                TextSpan(text: 'Have a project in mind? Fill the form or email directly to '),
                                TextSpan(
                                  text: 'aniklinkin@gmail.com',
                                  style: TextStyle(
                                    color: HudColors.cyan,
                                    fontWeight: FontWeight.w600,
                                    shadows: [Shadow(color: HudColors.cyan, blurRadius: 8)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 12),
                    // Contact cards grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3.5,
                      children: [
                        _contactCard('PHONE', '+977 9863021878', 'tel:+9779863021878'),
                        _contactCard('EMAIL', 'aniklinkin@gmail.com', 'mailto:aniklinkin@gmail.com'),
                        _contactCard('LINKEDIN', 'Anik Shakya',
                            'https://www.linkedin.com/in/anik-shakya-67141b192/'),
                        _contactCard('INSTAGRAM', '@anik_shakya_',
                            'https://www.instagram.com/anik_shakya_'),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 12),
                    // Form panel
                    HudPanel(
                      child: _status == 'READY'
                          ? Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _inputField(
                                    label: 'YOUR NAME',
                                    controller: _nameCtrl,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _inputField(
                                    label: 'YOUR EMAIL ADDRESS',
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (!v.contains('@')) return 'Invalid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _inputField(
                                    label: 'TRANSMISSION MESSAGE',
                                    controller: _messageCtrl,
                                    maxLines: 3,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: _submit,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: HudColors.magenta),
                                          borderRadius: BorderRadius.circular(5),
                                          color: HudColors.magenta.withOpacity(0.08),
                                        ),
                                        child: Text('TRANSMIT MESSAGE',
                                            textAlign: TextAlign.center,
                                            style: HudTextStyles.mono(12, color: HudColors.magenta)
                                                .copyWith(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _status == 'SENDING'
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(
                                            color: HudColors.cyan, strokeWidth: 2),
                                        const SizedBox(height: 14),
                                        Text('INITIALIZING TRANSMISSION...',
                                            style: HudTextStyles.mono(13)),
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 52, height: 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: HudColors.green.withOpacity(0.1),
                                            border: Border.all(color: HudColors.green, width: 2),
                                          ),
                                          child: const Icon(Icons.check, color: HudColors.green, size: 24),
                                        ),
                                        const SizedBox(height: 12),
                                        Text('EMAIL CLIENT OPENED',
                                            style: HudTextStyles.header(16, color: Colors.white)),
                                        const SizedBox(height: 6),
                                        Text('Message prepared for aniklinkin@gmail.com',
                                            style: HudTextStyles.body(12, color: HudColors.textMuted)),
                                        const SizedBox(height: 16),
                                        GestureDetector(
                                          onTap: _reset,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: HudColors.cyan),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text('SEND ANOTHER MESSAGE',
                                                style: HudTextStyles.mono(11)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Full-width footer
        _footer(),
      ],
    );
  }

  Widget _contactCard(String label, String value, String url) => GestureDetector(
        onTap: () => _launch(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x80020208),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: HudColors.cyan.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$label ↗', style: HudTextStyles.mono(8, color: HudColors.cyan)),
              const SizedBox(height: 2),
              Text(value,
                  style: HudTextStyles.body(11, color: Colors.white).copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );

  Widget _footer() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xD9020208),
          border: Border(top: BorderSide(color: Color(0x4D00F0FF))),
        ),
        child: Column(
          children: [
            // Top row: identity + contact + socials
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlowText('ANIK SHAKYA',
                        style: HudTextStyles.header(14), glowColor: HudColors.cyan),
                    const SizedBox(height: 2),
                    Text('SENIOR FLUTTER & CROSS-PLATFORM DEVELOPER',
                        style: HudTextStyles.mono(8, color: HudColors.cyan)),
                    const SizedBox(height: 3),
                    Text('Naghbahal, Lalitpur, Nepal',
                        style: HudTextStyles.mono(9, color: HudColors.textMuted)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DIRECT CONTACT', style: HudTextStyles.mono(8, color: HudColors.cyan)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launch('mailto:aniklinkin@gmail.com'),
                      child: Text('aniklinkin@gmail.com',
                          style: HudTextStyles.mono(10, color: Colors.white)),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _launch('tel:+9779863021878'),
                      child: Text('+977 9863021878',
                          style: HudTextStyles.mono(10, color: Colors.white)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SOCIAL NETWORKS',
                        style: HudTextStyles.mono(8, color: HudColors.magenta)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _socialBadge('GitHub', 'https://github.com/AnikShakya', HudColors.cyan),
                        _socialBadge('LinkedIn',
                            'https://www.linkedin.com/in/anik-shakya-67141b192/', HudColors.magenta),
                        _socialBadge('Instagram',
                            'https://www.instagram.com/anik_shakya_', HudColors.amber),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0x14FFFFFF), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('© 2026 ANIK SHAKYA // ALL SYSTEMS OPERATIONAL',
                    style: HudTextStyles.mono(8, color: HudColors.textMuted)),
                Text('● SYSTEM STATUS: ONLINE',
                    style: HudTextStyles.mono(8, color: HudColors.green)),
              ],
            ),
          ],
        ),
      );

  Widget _socialBadge(String label, String url, Color color) => GestureDetector(
        onTap: () => _launch(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
            color: color.withOpacity(0.06),
          ),
          child: Text('$label ↗',
              style: HudTextStyles.mono(9, color: color).copyWith(fontWeight: FontWeight.bold)),
        ),
      );
}
