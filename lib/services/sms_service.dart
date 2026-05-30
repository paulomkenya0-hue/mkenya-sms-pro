import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/conversation.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final Telephony telephony = Telephony.instance;

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.sms,
      Permission.contacts,
      Permission.phone,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<List<Conversation>> loadConversations() async {
    try {
      final inbox = await telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
          SmsColumn.READ,
          SmsColumn.THREAD_ID,
        ],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      final Map<String, Conversation> threadMap = {};

      for (final sms in inbox) {
        final threadId = sms.threadId?.toString() ?? sms.address ?? '';
        final address = sms.address ?? '';
        final body = sms.body ?? '';
        final date = DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0);
        final isRead = (sms.read ?? 0) == 1;

        final message = Message(
          id: sms.id?.toString() ?? '',
          body: body,
          address: address,
          date: date,
          isSent: false,
          isRead: isRead,
        );

        if (!threadMap.containsKey(threadId)) {
          threadMap[threadId] = Conversation(
            threadId: threadId,
            address: address,
            lastMessage: body,
            lastMessageTime: date,
            unreadCount: isRead ? 0 : 1,
            messages: [message],
          );
        } else {
          threadMap[threadId]!.messages.add(message);
          if (!isRead) threadMap[threadId]!.unreadCount++;
        }
      }

      return threadMap.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Message>> loadMessages(String address) async {
    try {
      final inbox = await telephony.getInboxSms(
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals(address),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)],
      );
      final sent = await telephony.getSentSms(
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals(address),
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
          isRead: (sms.read ?? 0) == 1,
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

      messages.sort((a, b) => a.date.compareTo(b.date));
      return messages;
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendSms({
    required String to,
    required String message,
  }) async {
    try {
      await telephony.sendSms(to: to, message: message);
      return true;
    } catch (e) {
      return false;
    }
  }

  void listenForIncomingSms({
    required Function(SmsMessage) onMessage,
  }) {
    telephony.listenIncomingSms(
      onNewMessage: onMessage,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }
}

void backgroundMessageHandler(SmsMessage message) {}
