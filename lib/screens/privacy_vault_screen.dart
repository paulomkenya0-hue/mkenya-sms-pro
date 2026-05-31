import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class PrivacyVaultScreen extends StatefulWidget {
  const PrivacyVaultScreen({super.key});
  @override
  State<PrivacyVaultScreen> createState() => _PrivacyVaultScreenState();
}

class _PrivacyVaultScreenState extends State<PrivacyVaultScreen> {
  List<String> _hidden = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hidden = prefs.getStringList('vault_numbers') ?? [];
      _loading = false;
    });
  }

  Future<void> _add(String number) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _hidden.add(number));
    await prefs.setStringList('vault_numbers', _hidden);
  }

  Future<void> _remove(String number) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _hidden.remove(number));
    await prefs.setStringList('vault_numbers', _hidden);
  }

  void _showAdd(AppTheme theme) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ficha Namba', style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: theme.textPrimary),
          decoration: InputDecoration(
            hintText: '+254700000000',
            hintStyle: TextStyle(color: theme.textSecondary),
            filled: true,
            fillColor: theme.bubbleReceived,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ghairi', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                _add(ctrl.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ficha'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).current;
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          Container(
            color: theme.surface,
            padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 8, 16, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_rounded, color: theme.accent),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy Vault 🔒', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.textPrimary)),
                    Text('Mazungumzo ya siri', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.accent.withOpacity(0.2), theme.accent.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🕵️', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Namba zilizofichwa hapa hazionekani kwenye orodha ya kawaida. Zinafunguliwa na PIN yako tu.',
                    style: TextStyle(fontSize: 13, color: theme.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: theme.accent))
                : _hidden.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔐', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text('Vault iko tupu', style: TextStyle(color: theme.textSecondary, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Bonyeza + ili kuficha namba', style: TextStyle(color: theme.textSecondary.withOpacity(0.5), fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _hidden.length,
                        itemBuilder: (_, i) {
                          final num = _hidden[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.accent.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔒', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Namba Iliyofichwa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textPrimary)),
                                      Text(num, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _remove(num),
                                  icon: const Icon(Icons.visibility_off_rounded, color: Colors.orange, size: 22),
                                ),
                              ],
                            ),
                          ).animate(delay: (50 * i).ms).fadeIn().slideX(begin: 0.1);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdd(Provider.of<ThemeNotifier>(context, listen: false).current),
        backgroundColor: Provider.of<ThemeNotifier>(context).current.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
