import '../../domain/entities/message_entity.dart';
import '../../domain/entities/negotiation_enums.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.negotiationId,
    required super.senderId,
    required super.senderRole,
    required super.messageType,
    required super.content,
    super.metadata,
    required super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    MessageType type = MessageType.TEXT;
    switch (json['messageType']) {
      case 'IMAGE': type = MessageType.IMAGE; break;
      case 'PRICE_OFFER': type = MessageType.PRICE_OFFER; break;
      case 'PRICE_COUNTER': type = MessageType.PRICE_COUNTER; break;
      case 'DEAL_ACCEPTED': type = MessageType.DEAL_ACCEPTED; break;
      default: type = MessageType.TEXT;
    }

    return MessageModel(
      id: json['id'],
      negotiationId: json['negotiationId'],
      senderId: json['senderId'],
      senderRole: json['senderRole'],
      messageType: type,
      content: json['content'] ?? '',
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'negotiationId': negotiationId,
      'senderId': senderId,
      'senderRole': senderRole,
      'messageType': messageType.name,
      'content': content,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
