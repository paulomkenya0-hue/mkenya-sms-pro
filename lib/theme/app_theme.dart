import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════
//  MKENYA SMS PRO — Theme System
// ═══════════════════════════════════════════════════════════

class AppTheme {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color accent;
  final Color bubbleSent;
  final Color bubbleReceived;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const AppTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.accent,
    required this.bubbleSent,
    required this.bubbleReceived,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });
}

class AppThemes {
  static const midnightPro = AppTheme(
    id: 'midnight',
    name: 'Midnight Pro',
    background: Color(0xFF0A0A0F),
    surface: Color(0xFF13131A),
    accent: Color(0xFFE91E8C),
    bubbleSent: Color(0xFFE91E8C),
    bubbleReceived: Color(0xFF1E1E2E),
    textPrimary: Color(0xFFF0F0F5),
    textSecondary: Color(0xFF888899),
    isDark: true,
  );

  static const pureBlack = AppTheme(
    id: 'amoled',
    name: 'Pure Black',
    background: Color(0xFF000000),
    surface: Color(0xFF0D0D0D),
    accent: Color(0xFF00BCD4),
    bubbleSent: Color(0xFF00BCD4),
    bubbleReceived: Color(0xFF111111),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF777777),
    isDark: true,
  );

  static const nairobiSunset = AppTheme(
    id: 'sunset',
    name: 'Nairobi Sunset',
    background: Color(0xFF0F0A1A),
    surface: Color(0xFF1A1025),
    accent: Color(0xFFFF6B35),
    bubbleSent: Color(0xFFFF6B35),
    bubbleReceived: Color(0xFF1E1530),
    textPrimary: Color(0xFFF5EFF5),
    textSecondary: Color(0xFF887788),
    isDark: true,
  );

  static const karuraForest = AppTheme(
    id: 'forest',
    name: 'Karura Forest',
    background: Color(0xFF070F0A),
    surface: Color(0xFF0D1A11),
    accent: Color(0xFF4CAF50),
    bubbleSent: Color(0xFF4CAF50),
    bubbleReceived: Color(0xFF111A13),
    textPrimary: Color(0xFFEFF5EF),
    textSecondary: Color(0xFF778877),
    isDark: true,
  );

  static const pearlWhite = AppTheme(
    id: 'light',
    name: 'Pearl White',
    background: Color(0xFFF8F9FE),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFFE91E8C),
    bubbleSent: Color(0xFFE91E8C),
    bubbleReceived: Color(0xFFEEF0F8),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF888899),
    isDark: false,
  );

  static const List<AppTheme> all = [
    midnightPro,
    pureBlack,
    nairobiSunset,
    karuraForest,
    pearlWhite,
  ];

  static AppTheme getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => midnightPro);
  }
}

// ── ThemeNotifier (ChangeNotifier for live switching) ──────────────────────
class ThemeNotifier extends ChangeNotifier {
  AppTheme _current = AppThemes.midnightPro;
  AppTheme get current => _current;

  ThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('theme_id') ?? 'midnight';
    _current = AppThemes.getById(id);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _current = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', theme.id);
    notifyListeners();
  }

  ThemeData get materialTheme => ThemeData(
    useMaterial3: true,
    brightness: _current.isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      brightness: _current.isDark ? Brightness.dark : Brightness.light,
      primary: _current.accent,
      onPrimary: Colors.white,
      secondary: _current.accent,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: _current.background,
      onBackground: _current.textPrimary,
      surface: _current.surface,
      onSurface: _current.textPrimary,
    ),
    scaffoldBackgroundColor: _current.background,
    fontFamily: 'DM Sans',
  );
}
