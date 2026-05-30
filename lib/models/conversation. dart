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
    if (diff.inMinutes < 1) return 'Sasa hivi';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Jana';
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
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }

  String get timeString {
    if (messages.isNotEmpty) return messages.last.timeString;
    return '';
  }
}
