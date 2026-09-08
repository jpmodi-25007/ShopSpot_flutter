import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat_entity.dart';

class ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSource({required this.apiClient});

  Future<ChatRoomEntity> createOrGetRoom(String targetUserId, {String? contextType, String? contextId}) async {
    final response = await apiClient.post(
      '/chats/rooms',
      data: {
        'targetUserId': targetUserId,
        if (contextType != null) 'contextType': contextType,
        if (contextId != null) 'contextId': contextId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _parseRoom(response.data);
    } else {
      throw Exception('Failed to create/get chat room');
    }
  }

  Future<List<ChatRoomEntity>> getMyRooms() async {
    final response = await apiClient.get('/chats/rooms');

    if (response.statusCode == 200) {
      final List data = response.data as List? ?? [];
      return data.map((json) => _parseRoom(json)).toList();
    } else {
      throw Exception('Failed to fetch chat rooms');
    }
  }

  Future<List<ChatMessageEntity>> getMessages(String roomId) async {
    final response = await apiClient.get('/chats/rooms/$roomId/messages');

    if (response.statusCode == 200) {
      final List data = response.data as List? ?? [];
      return data.map((json) => _parseMessage(json)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  Future<ChatMessageEntity> sendMessage(String roomId, String content) async {
    final response = await apiClient.post(
      '/chats/rooms/$roomId/messages',
      data: {'content': content},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _parseMessage(response.data);
    } else {
      throw Exception('Failed to send message');
    }
  }

  ChatRoomEntity _parseRoom(Map<String, dynamic> json) {
    return ChatRoomEntity(
      id: json['id'],
      participantA: json['participantA'],
      participantB: json['participantB'],
      contextType: json['contextType'],
      contextId: json['contextId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userA: json['userA'] ?? {},
      userB: json['userB'] ?? {},
      messages: (json['messages'] as List?)?.map((m) => _parseMessage(m)).toList() ?? [],
    );
  }

  ChatMessageEntity _parseMessage(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      content: json['content'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
