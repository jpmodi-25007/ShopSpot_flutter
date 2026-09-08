import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final String participantA;
  final String participantB;
  final String? contextType;
  final String? contextId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> userA;
  final Map<String, dynamic> userB;
  final List<ChatMessageEntity> messages;
  final ChatMessageEntity? lastMessage;
  final int unreadCount;

  const ChatRoomEntity({
    required this.id,
    required this.participantA,
    required this.participantB,
    this.contextType,
    this.contextId,
    required this.createdAt,
    required this.updatedAt,
    required this.userA,
    required this.userB,
    required this.messages,
    this.lastMessage,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, participantA, participantB, contextType, contextId, createdAt, updatedAt, userA, userB, messages, lastMessage, unreadCount];
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, roomId, senderId, content, isRead, createdAt];
}

