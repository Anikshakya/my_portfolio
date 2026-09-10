import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/hud_theme.dart';
import '../widgets/hud_panel.dart';
import '../widgets/glow_text.dart';
import '../data/projects_data.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _showAll = false;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showDetail(Project proj) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProjectModal(proj: proj, onLaunch: _launch),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedProjects = _showAll ? projects : projects.where((p) => p.isShowcase).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          HudPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROJECT MANIFESTS // DEPLOYED MISSIONS', style: HudTextStyles.mono(10)),
                    const SizedBox(height: 4),
                    GlowText('PROJECTS', style: HudTextStyles.header(18), glowColor: HudColors.cyan),
                  ],
                ),
                Row(
                  children: [
                    _tabBtn('SHOWCASE', !_showAll),
                    const SizedBox(width: 8),
                    _tabBtn('ALL', _showAll),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: displayedProjects.length,
            itemBuilder: (_, i) => _ProjectCard(
              project: displayedProjects[i],
              onTap: () => _showDetail(displayedProjects[i]),
            ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: i * 60)).slideY(begin: 0.06),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool active) => GestureDetector(
        onTap: () => setState(() => _showAll = label == 'ALL'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? HudColors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: active ? HudColors.cyan : HudColors.cyan.withOpacity(0.3)),
          ),
          child: Text(label,
              style: HudTextStyles.mono(10, color: active ? const Color(0xFF020208) : HudColors.cyan)
                  .copyWith(fontWeight: FontWeight.bold)),
        ),
      );
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});
  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          transform: _hovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xA6040818) : const Color(0x80020208),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? HudColors.cyan : HudColors.cyan.withOpacity(0.18),
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: HudColors.cyan.withOpacity(0.25), blurRadius: 16)]
                : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: HudColors.cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.apps_rounded, color: HudColors.cyan, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.project.title,
                            style: HudTextStyles.header(12, weight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(widget.project.category, style: HudTextStyles.mono(9, color: HudColors.cyan)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.project.status == 'STORE RELEASE'
                          ? HudColors.green.withOpacity(0.12)
                          : HudColors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: widget.project.status == 'STORE RELEASE'
                            ? HudColors.green.withOpacity(0.4)
                            : HudColors.amber.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      widget.project.status == 'STORE RELEASE' ? 'LIVE' : 'OSS',
                      style: HudTextStyles.mono(8,
                          color: widget.project.status == 'STORE RELEASE'
                              ? HudColors.green
                              : HudColors.amber),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(widget.project.shortDesc,
                    style: HudTextStyles.body(11.5, color: HudColors.textMuted),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.project.stack.take(3).map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HudColors.cyan.withOpacity(0.05),
                        border: Border.all(color: HudColors.cyan.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(t, style: HudTextStyles.mono(8)),
                    )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('TAP TO EXPAND ↗',
                      style: HudTextStyles.mono(9, color: HudColors.cyan.withOpacity(0.5))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectModal extends StatelessWidget {
  final Project proj;
  final Future<void> Function(String) onLaunch;

  const _ProjectModal({required this.proj, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF040A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: HudColors.cyan.withOpacity(0.15), blurRadius: 30)],
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: HudColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PROJECT_DOSSIER // MISSION_INTEL',
                    style: HudTextStyles.mono(10)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('[CLOSE X]',
                      style: HudTextStyles.mono(10, color: HudColors.cyan)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlowText(proj.title,
                style: HudTextStyles.header(20, weight: FontWeight.w800),
                glowColor: HudColors.cyan),
            const SizedBox(height: 4),
            Text(proj.category, style: HudTextStyles.mono(11, color: HudColors.cyan)),
            const SizedBox(height: 12),
            const Divider(color: Color(0x2500F0FF)),
            const SizedBox(height: 12),
            Text(proj.longDesc, style: HudTextStyles.body(13)),
            const SizedBox(height: 16),
            Text('MISSION METRICS:', style: HudTextStyles.mono(10, color: HudColors.textMuted)),
            const SizedBox(height: 8),
            ...proj.metrics.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('▶ ', style: TextStyle(color: HudColors.cyan, fontSize: 11)),
                      Expanded(child: Text(m, style: HudTextStyles.body(12.5))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: proj.stack.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: HudColors.cyan.withOpacity(0.06),
                      border: Border.all(color: HudColors.cyan.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(t, style: HudTextStyles.mono(10)),
                  )).toList(),
            ),
            const SizedBox(height: 20),
            if (proj.playstore != null)
              _storeBtn('PLAY STORE ↗', proj.playstore!, HudColors.green),
            if (proj.playstore != null && proj.appstore != null) const SizedBox(height: 10),
            if (proj.appstore != null)
              _storeBtn('APP STORE ↗', proj.appstore!, HudColors.cyan),
            if (proj.github != null) ...[
              const SizedBox(height: 10),
              _storeBtn('GITHUB ↗', proj.github!, HudColors.magenta),
            ],
          ],
        ),
      ),
    );
  }

  Widget _storeBtn(String label, String url, Color color) => GestureDetector(
        onTap: () => onLaunch(url),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(6),
            color: color.withOpacity(0.08),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: HudTextStyles.mono(11, color: color).copyWith(fontWeight: FontWeight.bold)),
        ),
      );
}
