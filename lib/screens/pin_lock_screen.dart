import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSetup;
  const PinLockScreen({super.key, this.isSetup = false});
  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with TickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _wrongPin = false;
  bool _success = false;
  int _attempts = 0;
  bool _locked = false;

  late AnimationController _particleCtrl;
  late AnimationController _gradientCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _shakeAnim;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final Random _random = Random();

  // Particles
  late List<Map<String, dynamic>> _particles;

  @override
  void initState() {
    super.initState();

    _particles = List.generate(40, (i) => {
      'x': _random.nextDouble(),
      'y': _random.nextDouble(),
      'size': _random.nextDouble() * 4 + 1,
      'speed': _random.nextDouble() * 0.3 + 0.05,
      'color': [
        const Color(0xFFE91E8C),
        const Color(0xFF9C27B0),
        const Color(0xFF00BCD4),
        const Color(0xFFFF6B35),
      ][_random.nextInt(4)],
      'opacity': _random.nextDouble() * 0.5 + 0.15,
    });

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    if (!widget.isSetup) {
      Future.delayed(const Duration(milliseconds: 600), _tryBiometric);
    }
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _gradientCtrl.dispose();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      if (!canAuth) return;
      final auth = await _localAuth.authenticate(
        localizedReason: 'Fungua Mkenya SMS Pro',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (auth && mounted) _onSuccess();
    } catch (_) {}
  }

  void _onTap(String num) {
    if (_locked || _success) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (widget.isSetup && !_isConfirming) {
        if (_pin.length < 4) _pin += num;
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      } else if (widget.isSetup && _isConfirming) {
        if (_confirmPin.length < 4) _confirmPin += num;
        if (_confirmPin.length == 4) _checkSetup();
      } else {
        if (_pin.length < 4) _pin += num;
        if (_pin.length == 4) _checkPin();
      }
    });
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      if (widget.isSetup && _isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_pin') ?? '';
    if (_pin == saved) {
      _onSuccess();
    } else {
      _onWrong();
    }
  }

  Future<void> _checkSetup() async {
    if (_pin == _confirmPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin', _pin);
      await prefs.setBool('pin_setup', true);
      _onSuccess();
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      setState(() { _wrongPin = true; _confirmPin = ''; });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() { _wrongPin = false; _isConfirming = false; _pin = ''; });
      });
    }
  }

  void _onWrong() {
    HapticFeedback.heavyImpact();
    _attempts++;
    _shakeCtrl.forward(from: 0);
    setState(() { _wrongPin = true; _pin = ''; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _wrongPin = false);
    });
    if (_attempts >= 5) {
      setState(() => _locked = true);
      Future.delayed(const Duration(minutes: 1), () {
        if (mounted) setState(() { _locked = false; _attempts = 0; });
      });
    }
  }

  void _onSuccess() {
    HapticFeedback.heavyImpact();
    setState(() => _success = true);
    Future.delayed(const Duration(milliseconds: 900), () {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_particleCtrl, _gradientCtrl, _shakeCtrl]),
        builder: (context, _) {
          final shakeOffset = _wrongPin
              ? sin(_shakeAnim.value * pi * 8) * 14
              : 0.0;

          return Stack(
            children: [
              // Animated gradient bg
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF0A0A0F), const Color(0xFF1A0A2E), _gradientCtrl.value)!,
                      Color.lerp(const Color(0xFF13131A), const Color(0xFF0A0A1A), _gradientCtrl.value)!,
                      const Color(0xFF000510),
                    ],
                  ),
                ),
              ),

              // Floating particles
              ..._particles.map((p) {
                final progress = (_particleCtrl.value + (p['speed'] as double)) % 1.0;
                final yPos = ((p['y'] as double) - progress * 0.4) % 1.0;
                return Positioned(
                  left: MediaQuery.of(context).size.width * (p['x'] as double),
                  top: MediaQuery.of(context).size.height * yPos,
                  child: Opacity(
                    opacity: (p['opacity'] as double) * (1 - progress * 0.3),
                    child: Container(
                      width: p['size'] as double,
                      height: p['size'] as double,
                      decoration: BoxDecoration(
                        color: p['color'] as Color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (p['color'] as Color).withOpacity(0.4),
                            blurRadius: (p['size'] as double) * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Expanding rings
              ...List.generate(3, (i) {
                final scale = (_particleCtrl.value + i * 0.33) % 1.0;
                return Center(
                  child: Opacity(
                    opacity: (1 - scale) * 0.2,
                    child: Transform.scale(
                      scale: 0.3 + scale * 3,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE91E8C), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Success flash
              if (_success)
                AnimatedOpacity(
                  opacity: _success ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: const Color(0xFFE91E8C).withOpacity(0.15),
                    child: Center(
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFE91E8C),
                        size: 90,
                      ).animate()
                          .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut)
                          .fadeIn(),
                    ),
                  ),
                ),

              // Main content — shakes on wrong PIN
              Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // Glowing icon
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: 85, height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE91E8C).withOpacity(
                                  0.3 + _pulseCtrl.value * 0.3,
                                ),
                                blurRadius: 30 + _pulseCtrl.value * 20,
                                spreadRadius: 3 + _pulseCtrl.value * 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 44),
                        ),
                      ).animate().scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        widget.isSetup
                            ? (_isConfirming ? 'Thibitisha PIN' : 'Weka PIN Mpya')
                            : 'Mkenya SMS Pro',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                      const SizedBox(height: 6),

                      // Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _locked
                              ? '🔒 Imefungwa dakika 1'
                              : _wrongPin
                                  ? '❌ PIN si sahihi!'
                                  : widget.isSetup
                                      ? (_isConfirming
                                          ? 'Rudia PIN uliyoweka'
                                          : 'Chagua PIN ya tarakimu 4')
                                      : 'Weka PIN ili uingie',
                          key: ValueKey(_wrongPin.toString() + _locked.toString()),
                          style: TextStyle(
                            fontSize: 14,
                            color: _wrongPin
                                ? Colors.redAccent
                                : _locked
                                    ? Colors.orange
                                    : Colors.white.withOpacity(0.55),
                            fontWeight: (_wrongPin || _locked) ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // PIN dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final cur = (widget.isSetup && _isConfirming) ? _confirmPin : _pin;
                          final filled = i < cur.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.elasticOut,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            width: filled ? 22 : 16,
                            height: filled ? 22 : 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: filled ? const Color(0xFFE91E8C) : Colors.transparent,
                              border: Border.all(
                                color: filled ? const Color(0xFFE91E8C) : Colors.white30,
                                width: 2,
                              ),
                              boxShadow: filled ? [
                                BoxShadow(
                                  color: const Color(0xFFE91E8C).withOpacity(0.7),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                ),
                              ] : null,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 52),

                      // Number pad
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 44),
                        child: Column(
                          children: [
                            _row(['1', '2', '3']),
                            const SizedBox(height: 18),
                            _row(['4', '5', '6']),
                            const SizedBox(height: 18),
                            _row(['7', '8', '9']),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _specialBtn(Icons.fingerprint_rounded, _tryBiometric, pulse: true),
                                _numBtn('0'),
                                _specialBtn(Icons.backspace_rounded, _onDelete),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (_attempts > 0 && !_locked)
                        Text(
                          'Majaribio yaliyobaki: ${5 - _attempts}',
                          style: TextStyle(
                            color: Colors.orange.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ).animate().fadeIn(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(List<String> nums) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: nums.map(_numBtn).toList(),
  );

  Widget _numBtn(String n) => GestureDetector(
    onTap: () => _onTap(n),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 74, height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.13),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E8C).withOpacity(0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(n,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Colors.white),
        ),
      ),
    ),
  );

  Widget _specialBtn(IconData icon, VoidCallback onTap, {bool pulse = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          width: 74, height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(
            icon,
            size: 28,
            color: pulse
                ? Color.lerp(const Color(0xFFE91E8C), const Color(0xFF9C27B0), _pulseCtrl.value)
                : Colors.white54,
          ),
        ),
      ),
    );
  }
}
