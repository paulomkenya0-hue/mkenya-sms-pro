import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'chat_screen.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});
  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _searchCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchCtrl.addListener(_filter);
  }

  Future<void> _loadContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          _contacts = contacts;
          _filtered = contacts;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _contacts.where((c) =>
        c.displayName.toLowerCase().contains(q) ||
        c.phones.any((p) => p.number.contains(q))
      ).toList();
    });
  }

  void _openChat(String name, String phone) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversation: Conversation(
            threadId: phone,
            address: phone,
            contactName: name,
            lastMessage: '',
            lastMessageTime: DateTime.now(),
            unreadCount: 0,
            messages: [],
          ),
        ),
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
          // Header
          Container(
            color: theme.surface,
            padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 8, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: theme.accent),
                    ),
                    Text(
                      'New Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // To: field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.bubbleReceived,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Text('To: ', style: TextStyle(color: theme.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                      Expanded(
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(fontSize: 14, color: theme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Jina au nambari ya simu...',
                            hintStyle: TextStyle(color: theme.textSecondary, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (v) {
                            if (v.isNotEmpty) _openChat(v, v);
                          },
                        ),
                      ),
                      if (_phoneCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => _openChat(_phoneCtrl.text, _phoneCtrl.text),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Go', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Search contacts
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.bubbleReceived,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.accent.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.search_rounded, size: 16, color: theme.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(fontSize: 13, color: theme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Tafuta contacts...',
                            hintStyle: TextStyle(color: theme.textSecondary, fontSize: 13),
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
          ),

          // Contacts list
          Expanded(
            child: _loading
              ? Center(child: CircularProgressIndicator(color: theme.accent))
              : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.contacts_rounded, size: 56, color: theme.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('Hakuna contacts', style: TextStyle(color: theme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final c = _filtered[i];
                      final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
                      final initials = c.displayName.length >= 2
                          ? c.displayName.substring(0, 2).toUpperCase()
                          : c.displayName.toUpperCase();
                      final colors = [
                        const Color(0xFFE91E8C), const Color(0xFF00BCD4),
                        const Color(0xFF4CAF50), const Color(0xFFFF6B35),
                        const Color(0xFF9C27B0), const Color(0xFF2196F3),
                      ];
                      final color = colors[i % colors.length];
                      return ListTile(
                        onTap: () => _openChat(c.displayName, phone),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                          ),
                          child: Center(
                            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                        ),
                        title: Text(c.displayName, style: TextStyle(color: theme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(phone, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right_rounded, color: theme.textSecondary.withOpacity(0.4)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}
