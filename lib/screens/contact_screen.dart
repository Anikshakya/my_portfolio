import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/scroll_animate.dart';
import '../widgets/app_page_header.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cyanColor = colorScheme.primary != Colors.transparent
        ? colorScheme.primary
        : HudColors.cyan;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final hPad = isWide ? 40.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppPageHeader(
                    eyebrow: 'COMMUNICATION CHANNEL',
                    title: 'GET IN TOUCH',
                    summary: '// OPEN CHANNEL FOR NEW PROJECTS & COLLABORATION',
                    isWide: isWide,
                    animationKey: 'contact_header',
                  ),

                  const SizedBox(height: 32),

                  isWide
                      ? _wideLayout(
                          colorScheme,
                          cyanColor,
                        )
                      : _narrowLayout(
                          colorScheme,
                          cyanColor,
                        ),

                  const SizedBox(height: 24),

                  // ALWAYS KEEP FOOTER
                  _footerBar(
                    colorScheme,
                    cyanColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // LAYOUT
  // ===========================================================================

  Widget _wideLayout(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: ScrollAnimate(
            key: const ValueKey('contact_form'),
            child: _contactForm(
              colorScheme,
              cyanColor,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: ScrollAnimate(
            key: const ValueKey('contact_info'),
            child: _contactInfo(
              colorScheme,
              cyanColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    return Column(
      children: [
        ScrollAnimate(
          key: const ValueKey('contact_form_mobile'),
          child: _contactForm(
            colorScheme,
            cyanColor,
          ),
        ),
        const SizedBox(height: 16),
        ScrollAnimate(
          key: const ValueKey('contact_info_mobile'),
          child: _contactInfo(
            colorScheme,
            cyanColor,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CONTACT FORM
  // ===========================================================================

  Widget _contactForm(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    return HudPanel(
      padding: const EdgeInsets.all(24),
      borderColor: cyanColor.withValues(alpha:0.25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              label: 'MESSAGE TRANSMISSION',
              icon: Icons.send_outlined,
              colorScheme: colorScheme,
              cyanColor: cyanColor,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;

                if (compact) {
                  return Column(
                    children: [
                      _field(
                        controller: _nameController,
                        label: 'YOUR NAME',
                        hint: 'Enter your name',
                        icon: Icons.person_outline_rounded,
                        colorScheme: colorScheme,
                        cyanColor: cyanColor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        hint: 'you@example.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        colorScheme: colorScheme,
                        cyanColor: cyanColor,
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email is required';
                          }

                          final valid = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email);

                          if (!valid) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(
                        controller: _nameController,
                        label: 'YOUR NAME',
                        hint: 'Enter your name',
                        icon: Icons.person_outline_rounded,
                        colorScheme: colorScheme,
                        cyanColor: cyanColor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        hint: 'you@example.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        colorScheme: colorScheme,
                        cyanColor: cyanColor,
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email is required';
                          }

                          final valid = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email);

                          if (!valid) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            _field(
              controller: _subjectController,
              label: 'SUBJECT',
              hint: 'Project inquiry',
              icon: Icons.subject_rounded,
              colorScheme: colorScheme,
              cyanColor: cyanColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _field(
              controller: _messageController,
              label: 'MESSAGE',
              hint: 'Tell me about your project...',
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 7,
              colorScheme: colorScheme,
              cyanColor: cyanColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Message is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _sendButton(
              colorScheme,
              cyanColor,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FORM FIELD
  // ===========================================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required Color cyanColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    final fillColor = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha:0.035),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha:0.035),
            colorScheme.surface,
          );

    final borderColor = colorScheme.outline.withValues(alpha:
      isDark ? 0.28 : 0.22,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HudTextStyles.mono(
            9.5,
            color: colorScheme.onSurface.withValues(alpha:0.58),
          ).copyWith(
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : 5,
          cursorColor: cyanColor,
          style: HudTextStyles.body(
            13,
            color: colorScheme.onSurface,
          ).copyWith(
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: HudTextStyles.body(
              12.5,
              color: colorScheme.onSurface.withValues(alpha:0.35),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 8,
                top: maxLines > 1 ? 14 : 0,
              ),
              child: Icon(
                icon,
                size: 17,
                color: colorScheme.onSurface.withValues(alpha:0.42),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: maxLines > 1 ? 12 : 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: cyanColor.withValues(alpha:0.7),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: colorScheme.error.withValues(alpha:0.7),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1.2,
              ),
            ),
            errorStyle: HudTextStyles.mono(
              8.5,
              color: colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SEND BUTTON
  // ===========================================================================

  Widget _sendButton(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: _HoverButton(
        colorScheme: colorScheme,
        accentColor: cyanColor,
        onTap: _sendMessage,
        child: _sending
            ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TRANSMIT MESSAGE',
                    style: HudTextStyles.mono(
                      10,
                      color: colorScheme.onPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_sending) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _sending = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final body = '''
Hello Anik,

Name: $name
Email: $email

$message

Regards,
$name
''';

    final uri = Uri(
      scheme: 'mailto',
      path: 'aniklinkin@gmail.com',
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && mounted) {
        _showMessage(
          'Unable to open your email application.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to open your email application.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  // ===========================================================================
  // CONTACT INFO
  // ===========================================================================

  Widget _contactInfo(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    return HudPanel(
      padding: const EdgeInsets.all(24),
      borderColor: colorScheme.outline.withValues(alpha:0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cyanColor.withValues(alpha:0.08),
                    border: Border.all(
                      color: cyanColor.withValues(alpha:0.28),
                    ),
                  ),
                  child: Icon(
                    Icons.sensors_rounded,
                    size: 17,
                    color: cyanColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SOCIALS AND LINKS',
                  textAlign: TextAlign.center,
                  style: HudTextStyles.header(
                    17,
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ).copyWith(
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'OPEN COMMUNICATION CHANNEL',
                  textAlign: TextAlign.center,
                  style: HudTextStyles.mono(
                    8.5,
                    color: cyanColor,
                  ).copyWith(
                    letterSpacing: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha:0.16),
          ),
          const SizedBox(height: 18),
          _contactDetail(
            icon: Icons.email_outlined,
            label: 'EMAIL',
            value: 'aniklinkin@gmail.com',
            colorScheme: colorScheme,
            accentColor: cyanColor,
            onTap: () => _launchExternal(
              Uri(
                scheme: 'mailto',
                path: 'aniklinkin@gmail.com',
              ),
            ),
          ),
          const SizedBox(height: 10),
          _contactDetail(
            icon: Icons.phone_outlined,
            label: 'PHONE',
            value: '+977 9863021878',
            colorScheme: colorScheme,
            accentColor: HudColors.green,
            onTap: () => _launchExternal(
              Uri(
                scheme: 'tel',
                path: '+9779863021878',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SOCIAL NETWORKS',
              style: HudTextStyles.mono(
                9,
                color: colorScheme.onSurface.withValues(alpha:0.52),
              ).copyWith(
                letterSpacing: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _socialLinks(
            colorScheme,
            cyanColor,
          ),
          const SizedBox(height: 20),
          _availabilityCard(
            colorScheme,
            cyanColor,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONTACT DETAIL
  // ===========================================================================

  Widget _contactDetail({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return _InteractiveContainer(
      colorScheme: colorScheme,
      accentColor: accentColor,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha:0.07),
              border: Border.all(
                color: accentColor.withValues(alpha:0.18),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: HudTextStyles.mono(
                    8,
                    color: colorScheme.onSurface.withValues(alpha:0.48),
                  ).copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: HudTextStyles.body(
                    12.5,
                    color: colorScheme.onSurface,
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_outward_rounded,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha:0.35),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SOCIAL LINKS
  // ===========================================================================

  Widget _socialLinks(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    final links = [
      _SocialLink(
        name: 'GITHUB',
        icon: Icons.code_rounded,
        url: 'https://github.com/AnikShakya',
        color: cyanColor,
      ),
      _SocialLink(
        name: 'LINKEDIN',
        icon: Icons.work_outline_rounded,
        url: 'https://www.linkedin.com/in/anik-shakya-67141b192/',
        color: colorScheme.secondary,
      ),
      const _SocialLink(
        name: 'INSTAGRAM',
        icon: Icons.camera_alt_outlined,
        url: 'https://www.instagram.com/anik_shakya_',
        color: Color(0xFFE76F9F),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;

        if (compact) {
          return Column(
            children: links.map((link) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: SizedBox(
                  width: double.infinity,
                  child: _socialButton(
                    link,
                    colorScheme,
                  ),
                ),
              );
            }).toList(),
          );
        }

        return Row(
          children: links.map((link) {
            final isLast = link == links.last;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isLast ? 0 : 7,
                ),
                child: _socialButton(
                  link,
                  colorScheme,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _socialButton(
    _SocialLink link,
    ColorScheme colorScheme,
  ) {
    return _SocialHoverButton(
      link: link,
      colorScheme: colorScheme,
      onTap: () => _launchExternal(
        Uri.parse(link.url),
      ),
    );
  }

  // ===========================================================================
  // AVAILABILITY
  // ===========================================================================

  Widget _availabilityCard(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    final isDark = colorScheme.brightness == Brightness.dark;

    final background = isDark
        ? Color.alphaBlend(
            cyanColor.withValues(alpha:0.035),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            cyanColor.withValues(alpha:0.045),
            colorScheme.surface,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: cyanColor.withValues(alpha:0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: HudColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HudColors.green.withValues(alpha:0.35),
                  blurRadius: 7,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT AVAILABILITY',
                  style: HudTextStyles.mono(
                    8.5,
                    color: HudColors.green,
                  ).copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Open to freelance projects, collaborations and international opportunities.',
                  style: HudTextStyles.body(
                    11.5,
                    color: colorScheme.onSurface.withValues(alpha:0.62),
                  ).copyWith(
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _footerBar(
    ColorScheme colorScheme,
    Color cyanColor,
  ) {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    final timestamp = '$year-$month-$day // $hour:$minute';

    final isDark = colorScheme.brightness == Brightness.dark;

    /*
     * Theme-aware footer.
     *
     * Dark:
     *   subtle dark surface
     *
     * Light:
     *   subtle tinted light surface
     */
    final footerSurface = isDark
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha:0.025),
            colorScheme.surface,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha:0.025),
            colorScheme.surface,
          );

    final footerBorder = colorScheme.outline.withValues(alpha:
      isDark ? 0.18 : 0.22,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: footerSurface,
        border: Border.all(
          color: footerBorder,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '© $year ANIK SHAKYA // ALL SYSTEMS OPERATIONAL',
                  textAlign: TextAlign.center,
                  style: HudTextStyles.mono(
                    8.5,
                    color: colorScheme.onSurface.withValues(alpha:0.52),
                  ).copyWith(
                    letterSpacing: 0.65,
                  ),
                ),
                const SizedBox(height: 7),
                _footerStatus(
                  colorScheme,
                  cyanColor,
                  timestamp,
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '© $year ANIK SHAKYA // ALL SYSTEMS OPERATIONAL',
                  overflow: TextOverflow.ellipsis,
                  style: HudTextStyles.mono(
                    8.5,
                    color: colorScheme.onSurface.withValues(alpha:0.52),
                  ).copyWith(
                    letterSpacing: 0.65,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _footerStatus(
                colorScheme,
                cyanColor,
                timestamp,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _footerStatus(
    ColorScheme colorScheme,
    Color cyanColor,
    String timestamp,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: HudColors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: HudColors.green.withValues(alpha:0.35),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'ONLINE',
          style: HudTextStyles.mono(
            8.5,
            color: HudColors.green,
          ).copyWith(
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          timestamp,
          style: HudTextStyles.mono(
            8.5,
            color: colorScheme.onSurface.withValues(alpha:0.42),
          ).copyWith(
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION HEADER
  // ===========================================================================

  Widget _sectionHeader({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required Color cyanColor,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: cyanColor.withValues(alpha:0.07),
            border: Border.all(
              color: cyanColor.withValues(alpha:0.2),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            icon,
            size: 15,
            color: cyanColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: HudTextStyles.mono(
              10,
              color: colorScheme.onSurface.withValues(alpha:0.65),
            ).copyWith(
              letterSpacing: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // EXTERNAL LINK
  // ===========================================================================

  Future<void> _launchExternal(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && mounted) {
        _showMessage(
          'Unable to open this link.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to open this link.',
          isError: true,
        );
      }
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: HudTextStyles.body(
            12,
            color: colorScheme.onInverseSurface,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? colorScheme.error : colorScheme.inverseSurface,
      ),
    );
  }
}

// =============================================================================
// SOCIAL LINK MODEL
// =============================================================================

class _SocialLink {
  final String name;
  final IconData icon;
  final String url;
  final Color color;

  const _SocialLink({
    required this.name,
    required this.icon,
    required this.url,
    required this.color,
  });
}

// =============================================================================
// SOCIAL LINK HOVER
// =============================================================================

class _SocialHoverButton extends StatefulWidget {
  final _SocialLink link;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SocialHoverButton({
    required this.link,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<_SocialHoverButton> createState() => _SocialHoverButtonState();
}

class _SocialHoverButtonState extends State<_SocialHoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.colorScheme.brightness == Brightness.dark;

    final normalBackground = isDark
        ? Color.alphaBlend(
            widget.link.color.withValues(alpha:0.025),
            widget.colorScheme.surface,
          )
        : Color.alphaBlend(
            widget.link.color.withValues(alpha:0.04),
            widget.colorScheme.surface,
          );

    final hoverBackground = Color.alphaBlend(
      widget.link.color.withValues(alpha:
        isDark ? 0.10 : 0.075,
      ),
      widget.colorScheme.surface,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,

          // Noticeable but restrained movement.
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _hovered ? -2.0 : 0.0,
            ),

          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: _hovered ? hoverBackground : normalBackground,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _hovered
                  ? widget.link.color.withValues(alpha:0.70)
                  : widget.colorScheme.outline.withValues(alpha:
                      isDark ? 0.24 : 0.25,
                    ),
              width: _hovered ? 1.2 : 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.link.color.withValues(alpha:
                        isDark ? 0.18 : 0.10,
                      ),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: _hovered
                      ? widget.link.color
                      : widget.colorScheme.onSurface.withValues(alpha:0.68),
                ),
                child: Icon(
                  widget.link.icon,
                  size: 14,
                  color: _hovered
                      ? widget.link.color
                      : widget.colorScheme.onSurface.withValues(alpha:0.58),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.link.name,
                  overflow: TextOverflow.ellipsis,
                  style: HudTextStyles.mono(
                    8.5,
                    color: _hovered
                        ? widget.link.color
                        : widget.colorScheme.onSurface.withValues(alpha:0.72),
                  ).copyWith(
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _hovered ? 0.08 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.north_east_rounded,
                  size: 10,
                  color: _hovered
                      ? widget.link.color
                      : widget.colorScheme.onSurface.withValues(alpha:0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INTERACTIVE CONTACT CONTAINER
// =============================================================================

class _InteractiveContainer extends StatefulWidget {
  final Widget child;
  final ColorScheme colorScheme;
  final Color accentColor;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const _InteractiveContainer({
    required this.child,
    required this.colorScheme,
    required this.accentColor,
    required this.onTap,
    required this.padding,
  });

  @override
  State<_InteractiveContainer> createState() => _InteractiveContainerState();
}

class _InteractiveContainerState extends State<_InteractiveContainer> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.colorScheme.brightness == Brightness.dark;

    final normalSurface = isDark
        ? Color.alphaBlend(
            widget.colorScheme.onSurface.withValues(alpha:0.025),
            widget.colorScheme.surface,
          )
        : Color.alphaBlend(
            widget.accentColor.withValues(alpha:0.025),
            widget.colorScheme.surface,
          );

    final hoverSurface = Color.alphaBlend(
      widget.accentColor.withValues(alpha:
        isDark ? 0.07 : 0.055,
      ),
      widget.colorScheme.surface,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? hoverSurface : normalSurface,
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withValues(alpha:0.38)
                  : widget.colorScheme.outline.withValues(alpha:
                      isDark ? 0.18 : 0.2,
                    ),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// =============================================================================
// SEND BUTTON HOVER
// =============================================================================

class _HoverButton extends StatefulWidget {
  final ColorScheme colorScheme;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget child;

  const _HoverButton({
    required this.colorScheme,
    required this.accentColor,
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.colorScheme.brightness == Brightness.dark;

    final normalColor = widget.accentColor.withValues(alpha:
      isDark ? 0.88 : 0.92,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _hovered ? -1.0 : 0.0,
            ),
          decoration: BoxDecoration(
            color: _hovered ? widget.accentColor : normalColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha:
                        isDark ? 0.22 : 0.16,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
