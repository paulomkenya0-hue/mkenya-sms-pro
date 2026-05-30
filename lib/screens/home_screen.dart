import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/sms_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'new_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Conversation> _conversations = [];
  List<Conversation> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  int _activeTab = 0; // 0=All, 1=Unread, 2=Pinned
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadConversations();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final convos = await SmsService().loadConversations();
    setState(() {
      _conversations = convos;
      _filtered = convos;
      _loading = false;
    });
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _conversations.where((c) =>
        c.displayName.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q) ||
        c.address.contains(q)
      ).toList();
    });
  }

  List<Conversation> get _tabFiltered {
    switch (_activeTab) {
      case 1: return _filtered.where((c) => c.unreadCount > 0).toList();
      case 2: return _filtered.where((c) => c.isPinned).toList();
      default: return _filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).current;
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          _buildHeader(theme),
          _buildTabs(theme),
          Expanded(child: _loading ? _buildLoading(theme) : _buildList(theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const NewMessageScreen())),
        backgroundColor: theme.accent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      color: theme.surface,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.accent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paulo Mkenya',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search_rounded, color: theme.textSecondary),
              ),
              IconButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
                icon: Icon(Icons.settings_rounded, color: theme.textSecondary),
              ),
              _Avatar(name: 'PM', color: theme.accent, size: 36),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: theme.bubbleReceived,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.accent.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, size: 18, color: theme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(fontSize: 14, color: theme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search messages, contacts...',
                      hintStyle: TextStyle(color: theme.textSecondary, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AppTheme theme) {
    final tabs = ['All', 'Unread', 'Pinned'];
    return Container(
      color: theme.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          ...tabs.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _activeTab = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: _activeTab == e.key
                    ? theme.accent
                    : theme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _activeTab == e.key
                      ? Colors.white
                      : theme.textSecondary,
                ),
              ),
            ),
          )),
          const Spacer(),
          Text(
            '${_tabFiltered.length} chats',
            style: TextStyle(fontSize: 12, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(AppTheme theme) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, i) => _ShimmerTile(theme: theme)
          .animate(delay: (50 * i).ms)
          .fadeIn(),
    );
  }

  Widget _buildList(AppTheme theme) {
    final list = _tabFiltered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: theme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No messages yet',
                style: TextStyle(color: theme.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tap ✏️ to start a conversation',
                style: TextStyle(color: theme.textSecondary.withOpacity(0.5), fontSize: 13)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: theme.accent,
      onRefresh: _loadConversations,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final c = list[i];
          return _ConvoTile(
            convo: c,
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
            ),
          ).animate(delay: (30 * i).ms).fadeIn().slideX(begin: 0.05);
        },
      ),
    );
  }

  Widget _buildBottomNav(AppTheme theme) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.accent.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          _NavItem(icon: Icons.chat_bubble_rounded, label: 'Messages', active: true, color: theme.accent),
          _NavItem(icon: Icons.call_rounded, label: 'Calls', active: false, color: theme.accent),
          _NavItem(icon: Icons.lock_rounded, label: 'Vault', active: false, color: theme.accent),
          _NavItem(icon: Icons.auto_awesome_rounded, label: 'AI', active: false, color: theme.accent),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING ☀️';
    if (h < 17) return 'GOOD AFTERNOON 🌤️';
    return 'GOOD EVENING 🌙';
  }
}

// ── Conversation tile ──────────────────────────────────────
class _ConvoTile extends StatelessWidget {
  final Conversation convo;
  final AppTheme theme;
  final VoidCallback onTap;

  const _ConvoTile({required this.convo, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.accent.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                _Avatar(
                  name: convo.initials,
                  color: _colorFromString(convo.address),
                  size: 54,
                ),
                if (convo.isPinned)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.push_pin_rounded, size: 8, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: convo.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: theme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        convo.timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: convo.unreadCount > 0
                              ? theme.accent
                              : theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: convo.unreadCount > 0
                                ? theme.textPrimary.withOpacity(0.8)
                                : theme.textSecondary,
                            fontWeight: convo.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (convo.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.accent, theme.accent.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.accent.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '${convo.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _OptionTile(icon: Icons.push_pin_rounded, label: convo.isPinned ? 'Unpin' : 'Pin', color: theme),
            _OptionTile(icon: Icons.archive_rounded, label: 'Archive', color: theme),
            _OptionTile(icon: Icons.notifications_off_rounded, label: 'Mute', color: theme),
            _OptionTile(icon: Icons.block_rounded, label: 'Block', color: theme, isDestructive: true),
            _OptionTile(icon: Icons.delete_rounded, label: 'Delete', color: theme, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Color _colorFromString(String s) {
    final colors = [
      const Color(0xFFE91E8C), const Color(0xFF00BCD4),
      const Color(0xFF4CAF50), const Color(0xFFFF6B35),
      const Color(0xFF9C27B0), const Color(0xFF2196F3),
      const Color(0xFFFF9800), const Color(0xFF607D8B),
    ];
    return colors[s.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppTheme color;
  final bool isDestructive;
  const _OptionTile({required this.icon, required this.label, required this.color, this.isDestructive = false});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : color.accent),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : color.textPrimary, fontSize: 15)),
      onTap: () => Navigator.pop(context),
      dense: true,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const _Avatar({required this.name, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.9), color.withOpacity(0.5)],
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: size * 0.34,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.active, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: active ? color : color.withOpacity(0.4), size: 22),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: active ? color : color.withOpacity(0.4))),
        ],
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final AppTheme theme;
  const _ShimmerTile({required this.theme});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(7))),
                const SizedBox(height: 6),
                Container(height: 12, decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
