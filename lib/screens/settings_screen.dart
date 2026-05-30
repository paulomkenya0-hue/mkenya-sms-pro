import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).current;
    final sections = [
      {'icon': Icons.palette_rounded, 'title': 'Appearance & Themes', 'sub': 'Themes, wallpapers, colors', 'route': 'themes'},
      {'icon': Icons.text_fields_rounded, 'title': 'Typography', 'sub': 'Fonts, sizes, styles', 'route': 'fonts'},
      {'icon': Icons.lock_rounded, 'title': 'Privacy & Vault', 'sub': 'App lock, private conversations', 'route': 'privacy'},
      {'icon': Icons.auto_awesome_rounded, 'title': 'AI Assistant', 'sub': 'Replies, translations, tone', 'route': 'ai'},
      {'icon': Icons.notifications_rounded, 'title': 'Notifications', 'sub': 'Sounds, badges, quick reply', 'route': 'notif'},
      {'icon': Icons.cloud_rounded, 'title': 'Backup & Restore', 'sub': 'Cloud sync, local backup', 'route': 'backup'},
      {'icon': Icons.info_rounded, 'title': 'About', 'sub': 'Version 1.0.0 · Paulo Mkenya', 'route': 'about'},
    ];

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          // Header
          Container(
            color: theme.surface,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_rounded, color: theme.accent),
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: theme.textPrimary),
                    ),
                    Text('Customize your experience', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile card
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.accent.withOpacity(0.2), theme.accent.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [theme.accent, theme.accent.withOpacity(0.6)]),
                        ),
                        child: const Center(child: Text('PM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paulo Mkenya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                            Text('+254 700 000 000', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: theme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: Text('● Mkenya SMS Pro', style: TextStyle(fontSize: 10, color: theme.accent, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                // Settings items
                ...sections.asMap().entries.map((e) {
                  final s = e.value;
                  return _SettingsTile(
                    icon: s['icon'] as IconData,
                    title: s['title'] as String,
                    subtitle: s['sub'] as String,
                    theme: theme,
                    onTap: () {
                      if (s['route'] == 'themes') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()));
                      }
                    },
                  ).animate(delay: (60 * e.key).ms).fadeIn().slideX(begin: 0.05);
                }),

                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text('Mkenya SMS Pro v1.0.0', style: TextStyle(fontSize: 11, color: theme.textSecondary.withOpacity(0.5))),
                      const SizedBox(height: 4),
                      Text('By Paulo Mkenya · Smart · Fast · Personal', style: TextStyle(fontSize: 10, color: theme.textSecondary.withOpacity(0.3))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final AppTheme theme;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.accent.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: theme.accent.withOpacity(0.2)),
              ),
              child: Icon(icon, color: theme.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.textSecondary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Theme Settings Screen ──────────────────────────────────
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ThemeNotifier>(context);
    final theme = notifier.current;
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          Container(
            color: theme.surface,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_rounded, color: theme.accent)),
                Text('Themes', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: theme.textPrimary)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
              ),
              itemCount: AppThemes.all.length,
              itemBuilder: (context, i) {
                final t = AppThemes.all[i];
                final isActive = theme.id == t.id;
                return GestureDetector(
                  onTap: () => notifier.setTheme(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? t.accent : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isActive ? [BoxShadow(color: t.accent.withOpacity(0.3), blurRadius: 16)] : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: t.background,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [t.accent, t.accent.withOpacity(0.6)]),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(height: 8, width: 80, decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(4))),
                                  const SizedBox(height: 4),
                                  Container(height: 6, width: 60, decoration: BoxDecoration(color: t.bubbleReceived, borderRadius: BorderRadius.circular(3))),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 20, height: 20,
                                      decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: t.surface,
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(t.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
                                ),
                                if (isActive)
                                  Icon(Icons.check_circle_rounded, size: 16, color: t.accent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: (80 * i).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ),
        ],
      ),
    );
  }
}
