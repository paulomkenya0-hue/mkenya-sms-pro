import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _smsGranted = false;
  bool _contactsGranted = false;
  bool _isDefaultApp = false;

  final features = [
    {'icon': Icons.chat_bubble_rounded, 'title': 'Smart Messaging', 'desc': 'Lightning-fast SMS with intelligent conversation management'},
    {'icon': Icons.auto_awesome, 'title': 'AI Assistance', 'desc': 'Generate replies, translate, and summarize with built-in AI'},
    {'icon': Icons.palette_rounded, 'title': 'Beautiful Themes', 'desc': 'Premium themes, fonts, and full visual customization'},
    {'icon': Icons.lock_rounded, 'title': 'Advanced Privacy', 'desc': 'Private vault, biometric lock, and secure backups'},
    {'icon': Icons.tune_rounded, 'title': 'Full Customization', 'desc': 'Make it truly yours with endless personalization'},
  ];

  Future<void> _requestSms() async {
    final status = await Permission.sms.request();
    setState(() => _smsGranted = status.isGranted);
  }

  Future<void> _requestContacts() async {
    final status = await Permission.contacts.request();
    setState(() => _contactsGranted = status.isGranted);
  }

  Future<void> _getStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                children: [
                  const Text('👋', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to\nMkenya SMS Pro',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your premium messaging experience awaits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

            // Features list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: features.length,
                itemBuilder: (context, i) {
                  final f = features[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E1E2E).withOpacity(0.9),
                          const Color(0xFF13131A).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E8C).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE91E8C).withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            f['icon'] as IconData,
                            color: const Color(0xFFE91E8C),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                f['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (100 * i).ms).fadeIn().slideX(begin: 0.2);
                },
              ),
            ),

            // Permissions + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  _PermissionTile(
                    icon: Icons.message_rounded,
                    label: 'SMS Permissions',
                    granted: _smsGranted,
                    onTap: _requestSms,
                    accent: const Color(0xFFE91E8C),
                  ),
                  const SizedBox(height: 8),
                  _PermissionTile(
                    icon: Icons.contacts_rounded,
                    label: 'Contacts Access',
                    granted: _contactsGranted,
                    onTap: _requestContacts,
                    accent: const Color(0xFFE91E8C),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _getStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFFE91E8C).withOpacity(0.4),
                      ),
                      child: const Text(
                        'Get Started →',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool granted;
  final VoidCallback onTap;
  final Color accent;

  const _PermissionTile({
    required this.icon,
    required this.label,
    required this.granted,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: granted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: granted ? Colors.green.withOpacity(0.2) : accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: granted ? Colors.green.withOpacity(0.5) : accent.withOpacity(0.4),
                ),
              ),
              child: Text(
                granted ? '✓ Granted' : 'Allow',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: granted ? Colors.green : accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
