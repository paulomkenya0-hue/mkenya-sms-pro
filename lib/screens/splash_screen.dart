import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_lock_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _navigate();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    final pinSetup = prefs.getBool('pin_setup') ?? false;

    Widget next;
    if (!onboarded) {
      next = const OnboardingScreen();
    } else if (pinSetup) {
      next = const PinLockScreen(isSetup: false);
    } else {
      next = const PinLockScreen(isSetup: true);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
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
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // Background
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

              // Particles
              ...List.generate(30, (i) {
                final x = (i * 37 % 100) / 100.0;
                final y = (i * 53 % 100) / 100.0;
                final offset = (_ctrl.value + i * 0.07) % 1.0;
                final dy = sin(offset * pi * 2) * 20;
                final colors = [
                  const Color(0xFFE91E8C),
                  const Color(0xFF00BCD4),
                  const Color(0xFF9C27B0),
                ];
                return Positioned(
                  left: MediaQuery.of(context).size.width * x,
                  top: MediaQuery.of(context).size.height * y + dy,
                  child: Opacity(
                    opacity: 0.1 + (i % 4) * 0.08,
                    child: Container(
                      width: (i % 3 + 1) * 2.0,
                      height: (i % 3 + 1) * 2.0,
                      decoration: BoxDecoration(
                        color: colors[i % 3],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors[i % 3].withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Expanding rings
              ...List.generate(3, (i) {
                final scale = (_ctrl.value + i * 0.33) % 1.0;
                return Center(
                  child: Opacity(
                    opacity: (1 - scale) * 0.3,
                    child: Transform.scale(
                      scale: 0.5 + scale * 2,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE91E8C),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            color: const Color(0xFFE91E8C).withOpacity(
                              0.3 + sin(_ctrl.value * pi * 2) * 0.2,
                            ),
                            blurRadius: 40 + sin(_ctrl.value * pi * 2) * 15,
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

                    Text(
                      'MKENYA SMS PRO',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Smart · Fast · Personal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 3,
                        fontWeight: FontWeight.w300,
                      ),
                    ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
                  ],
                ),
              ),

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
                ).animate(delay: 1200.ms).fadeIn(duration: 600.ms),
              ),
            ],
          );
        },
      ),
    );
  }
}
