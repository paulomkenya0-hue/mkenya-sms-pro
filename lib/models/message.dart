// ═══════════════════════════════════════════════════════════
//  MKENYA SMS PRO — Data Models
// ═══════════════════════════════════════════════════════════

class Message {
  final String id;
  final String body;
  final String address;
  final DateTime date;
  final bool isSent;
  final bool isRead;
  bool isStarred;

  Message({
    required this.id,
    required this.body,
    required this.address,
    required this.date,
    required this.isSent,
    required this.isRead,
    this.isStarred = false,
  });

  String get timeString {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      return '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Conversation {
  final String threadId;
  final String address;
  String? contactName;
  String? contactPhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount;
  List<Message> messages;
  bool isPinned;
  bool isMuted;
  bool isArchived;
  bool isBlocked;

  Conversation({
    required this.threadId,
    required this.address,
    this.contactName,
    this.contactPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.messages,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    this.isBlocked = false,
  });

  String get displayName => contactName ?? address;

  String get initials {
    final name = displayName;
    if (name.length >= 2) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  String get timeString => lastMessageTime != DateTime(0)
    ? messages.isNotEmpty
      ? messages.last.timeString
      : ''
    : '';
}
