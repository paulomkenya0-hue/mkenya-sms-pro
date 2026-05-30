import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/sms_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Message> _messages = [];
  bool _showAI = false;
  bool _aiLoading = false;
  String _aiSuggestion = '';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages = widget.conversation.messages;
    _scrollToBottom();
    SmsService().listenForIncomingSms(onMessage: (sms) {
      if (sms.address == widget.conversation.address) {
        setState(() {
          _messages.add(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            body: sms.body ?? '',
            address: sms.address ?? '',
            date: DateTime.now(),
            isSent: false,
            isRead: false,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? text]) async {
    final body = text ?? _msgCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sending = true;
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        body: body,
        address: widget.conversation.address,
        date: DateTime.now(),
        isSent: true,
        isRead: true,
      ));
    });
    _msgCtrl.clear();
    _scrollToBottom();
    await SmsService().sendSms(to: widget.conversation.address, message: body);
    setState(() {
      _sending = false;
      _showAI = false;
      _aiSuggestion = '';
    });
  }

  Future<void> _getAISuggestion() async {
    setState(() { _showAI = true; _aiLoading = true; });
    final lastReceived = _messages.lastWhere((m) => !m.isSent, orElse: () => _messages.last);

    // Call Anthropic API
    try {
      // In production, use your API key via secure backend
      // For now we show a smart local suggestion
      await Future.delayed(const Duration(milliseconds: 800));
      final suggestions = [
        'Asante sana! Nitakujibu hivi karibuni. 🙏',
        'Sawa, nimepokea. Tutaonana! 👍',
        'Ndio, inaweza kufanyika. Tuongee zaidi?',
        'Pole kwa kuchelewa kujibu. Uko vipi?',
        'Nzuri sana! Nashukuri uniambie. ✨',
      ];
      setState(() {
        _aiSuggestion = suggestions[DateTime.now().millisecond % suggestions.length];
        _aiLoading = false;
      });
    } catch (e) {
      setState(() { _aiLoading = false; _showAI = false; });
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
          Expanded(child: _buildMessages(theme)),
          if (_showAI) _buildAIPanel(theme),
          _buildQuickReplies(theme),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      color: theme.surface,
      padding: EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: theme.accent),
          ),
          _AvatarSmall(
            name: widget.conversation.initials,
            color: _colorFrom(widget.conversation.address),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                Text(
                  widget.conversation.address,
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ],
            ),
          ),
          // AI Button
          GestureDetector(
            onTap: _getAISuggestion,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.accent.withOpacity(0.2), theme.accent.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.accent.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: theme.accent),
                  const SizedBox(width: 4),
                  Text('AI', style: TextStyle(fontSize: 12, color: theme.accent, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showChatOptions(context, theme),
            icon: Icon(Icons.more_vert_rounded, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(AppTheme theme) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        final showDate = i == 0 ||
            _messages[i].date.day != _messages[i - 1].date.day;
        return Column(
          children: [
            if (showDate) _DateDivider(date: msg.date, theme: theme),
            _MessageBubble(message: msg, theme: theme)
                .animate()
                .scale(begin: const Offset(0.85, 0.85), duration: 200.ms, curve: Curves.easeOut)
                .fadeIn(duration: 200.ms),
          ],
        );
      },
    );
  }

  Widget _buildAIPanel(AppTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.accent.withOpacity(0.15), theme.accent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: theme.accent),
              const SizedBox(width: 6),
              Text('AI SUGGESTION', style: TextStyle(fontSize: 11, color: theme.accent, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAI = false),
                child: Icon(Icons.close_rounded, size: 18, color: theme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_aiLoading)
            Row(
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.only(right: 6),
                width: 8, height: 8,
                decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle),
              ).animate(delay: (150 * i).ms).then().moveY(begin: 0, end: -6, duration: 400.ms, curve: Curves.easeInOut).then().moveY(begin: -6, end: 0, duration: 400.ms))
            )
          else ...[
            Text(_aiSuggestion, style: TextStyle(fontSize: 14, color: theme.textPrimary, height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() { _msgCtrl.text = _aiSuggestion; _showAI = false; }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.accent,
                      side: BorderSide(color: theme.accent.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Use This', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _sendMessage(_aiSuggestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Send Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildQuickReplies(AppTheme theme) {
    final replies = ['👍 Sawa!', 'Asante! 🙏', 'Nitakupigia', 'Naenda sasa', 'Subiri kidogo'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: replies.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(replies[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: theme.accent.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(18),
              color: theme.accent.withOpacity(0.08),
            ),
            child: Text(replies[i], style: TextStyle(fontSize: 12, color: theme.accent, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AppTheme theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.accent.withOpacity(0.08))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.attach_file_rounded, color: theme.textSecondary, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: theme.accent.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.bubbleReceived,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.accent.withOpacity(0.15)),
              ),
              child: TextField(
                controller: _msgCtrl,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 14, color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Andika ujumbe...',
                  hintStyle: TextStyle(color: theme.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _msgCtrl.text.trim().isNotEmpty
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _sendMessage,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [theme.accent, theme.accent.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: theme.accent.withOpacity(0.4), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('voice'),
                    onTap: () {},
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: theme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.mic_rounded, color: theme.accent, size: 22),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(leading: Icon(Icons.search_rounded, color: theme.accent), title: Text('Search', style: TextStyle(color: theme.textPrimary)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.push_pin_rounded, color: theme.accent), title: Text('Pin Conversation', style: TextStyle(color: theme.textPrimary)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.notifications_off_rounded, color: theme.accent), title: Text('Mute', style: TextStyle(color: theme.textPrimary)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.delete_rounded, color: Colors.red), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Color _colorFrom(String s) {
    final colors = [const Color(0xFFE91E8C), const Color(0xFF00BCD4), const Color(0xFF4CAF50), const Color(0xFFFF6B35), const Color(0xFF9C27B0)];
    return colors[s.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final AppTheme theme;
  const _MessageBubble({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.body));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1)),
          );
        },
        child: Container(
          margin: EdgeInsets.only(
            bottom: 4,
            left: isSent ? 60 : 0,
            right: isSent ? 0 : 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSent
                ? LinearGradient(colors: [theme.bubbleSent, theme.bubbleSent.withOpacity(0.85)])
                : null,
            color: isSent ? null : theme.bubbleReceived,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isSent ? 18 : 4),
              bottomRight: Radius.circular(isSent ? 4 : 18),
            ),
            boxShadow: isSent ? [
              BoxShadow(color: theme.accent.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
            ] : null,
            border: isSent ? null : Border.all(color: theme.accent.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.body,
                style: TextStyle(
                  fontSize: 14,
                  color: isSent ? Colors.white : theme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSent ? Colors.white70 : theme.textSecondary,
                    ),
                  ),
                  if (isSent) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.done_all_rounded, size: 12, color: Colors.white70),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  final AppTheme theme;
  const _DateDivider({required this.date, required this.theme});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.accent.withOpacity(0.15))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
          ),
          Expanded(child: Divider(color: theme.accent.withOpacity(0.15))),
        ],
      ),
    );
  }
}

class _AvatarSmall extends StatelessWidget {
  final String name;
  final Color color;
  const _AvatarSmall({required this.name, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.5)],
        ),
      ),
      child: Center(
        child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}
