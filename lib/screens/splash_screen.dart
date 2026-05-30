import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _navigate();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            onboarded ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.4),
                radius: 1.5,
                colors: [
                  Color(0xFF1a0a2e),
                  Color(0xFF0a0a0f),
                  Color(0xFF000510),
                ],
              ),
            ),
          ),

          // Floating particles
          ...List.generate(20, (i) => _Particle(
            index: i,
            controller: _particleController,
          )),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E8C).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                // App Name
                Text(
                  'MKENYA SMS PRO',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  'Smart · Fast · Personal',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w300,
                  ),
                )
                    .animate(delay: 900.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),

          // Developer credit
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: Text(
              'Developed by Paulo Mkenya',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.25),
                letterSpacing: 1,
              ),
            )
                .animate(delay: 1400.ms)
                .fadeIn(duration: 600.ms),
          ),
        ],
      ),
    );
  }
}

// ── Floating particle widget ───────────────────────────────
class _Particle extends StatelessWidget {
  final int index;
  final AnimationController controller;

  const _Particle({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFE91E8C),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
    ];
    final color = colors[index % 3];
    final x = (index * 37 % 100) / 100.0;
    final y = (index * 53 % 100) / 100.0;
    final size = (index % 3 + 1).toDouble() * 1.5;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = (controller.value + index * 0.1) % 1.0;
        final dy = (offset < 0.5) ? offset * -20 : (1 - offset) * -20;
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y + dy,
          child: Opacity(
            opacity: 0.15 + (index % 4) * 0.1,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
