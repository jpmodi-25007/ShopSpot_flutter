import 'negotiation_enums.dart';

class MessageEntity {
  final String id;
  final String negotiationId;
  final String senderId;
  final String senderRole; // 'customer' or 'shopkeeper'
  final MessageType messageType;
  final String content;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.negotiationId,
    required this.senderId,
    required this.senderRole,
    required this.messageType,
    required this.content,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });
}
