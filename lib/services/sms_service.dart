import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/conversation.dart';
import '../models/message.dart';

// ═══════════════════════════════════════════════════════════
//  MKENYA SMS PRO — SMS Service (Real SMS read/send)
// ═══════════════════════════════════════════════════════════

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final Telephony telephony = Telephony.instance;

  // ── Request all permissions ────────────────────────────
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.sms,
      Permission.contacts,
      Permission.phone,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  // ── Load all conversations from device ────────────────
  Future<List<Conversation>> loadConversations() async {
    try {
      final threads = await telephony.getConversations(
        filter: ConversationFilter.no,
        sortOrder: [OrderBy(ConversationProjection.DATE, sort: Sort.DESC)],
      );

      List<Conversation> convos = [];
      for (final thread in threads) {
        final msgs = await loadMessages(thread.threadId.toString());
        if (msgs.isEmpty) continue;
        final last = msgs.last;

        convos.add(Conversation(
          threadId: thread.threadId.toString(),
          address: thread.snippet ?? '',
          contactName: null, // filled by ContactService
          lastMessage: last.body,
          lastMessageTime: last.date,
          unreadCount: thread.messageCount ?? 0,
          messages: msgs,
        ));
      }
      return convos;
    } catch (e) {
      return [];
    }
  }

  // ── Load messages for a thread ────────────────────────
  Future<List<Message>> loadMessages(String threadId) async {
    try {
      // Inbox messages
      final inbox = await telephony.getInboxSms(
        filter: SmsFilter.where(SmsColumn.THREAD_ID).equals(threadId),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)],
      );

      // Sent messages
      final sent = await telephony.getSentSms(
        filter: SmsFilter.where(SmsColumn.THREAD_ID).equals(threadId),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)],
      );

      List<Message> messages = [];

      for (final sms in inbox) {
        messages.add(Message(
          id: sms.id?.toString() ?? '',
          body: sms.body ?? '',
          address: sms.address ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
          isSent: false,
          isRead: sms.read == SmsReadStatus.READ,
        ));
      }

      for (final sms in sent) {
        messages.add(Message(
          id: sms.id?.toString() ?? '',
          body: sms.body ?? '',
          address: sms.address ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
          isSent: true,
          isRead: true,
        ));
      }

      // Sort by date
      messages.sort((a, b) => a.date.compareTo(b.date));
      return messages;
    } catch (e) {
      return [];
    }
  }

  // ── Send SMS ──────────────────────────────────────────
  Future<bool> sendSms({
    required String to,
    required String message,
  }) async {
    try {
      await telephony.sendSms(
        to: to,
        message: message,
        statusListener: (status) {
          // SmsSendStatus.SENT / DELIVERED
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Mark as read ──────────────────────────────────────
  Future<void> markAsRead(String threadId) async {
    // Uses Android ContentResolver
    await telephony.requestSmsPermissions;
  }

  // ── Delete conversation ───────────────────────────────
  Future<void> deleteThread(String threadId) async {
    // Requires WRITE_SMS permission
  }

  // ── Listen for new SMS ────────────────────────────────
  void listenForIncomingSms({
    required Function(SmsMessage) onMessage,
  }) {
    telephony.listenIncomingSms(
      onNewMessage: onMessage,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }
}

// Background handler (top-level function required by telephony)
void backgroundMessageHandler(SmsMessage message) {
  // Handle background SMS
}
