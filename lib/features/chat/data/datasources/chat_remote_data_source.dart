import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat_entity.dart';

class ChatRemoteDataSource {
  final ApiClient apiClient;
  final Logger _logger = Logger();

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
      return _parseRoom(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create/get chat room');
    }
  }

  Future<List<ChatRoomEntity>> getMyRooms() async {
    try {
      final response = await apiClient.get('/chats/rooms');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => _parseRoom(json))
              .toList();
        }
        return [];
      } else {
        _logger.w('[Chat] getMyRooms returned ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Gracefully swallow 500 or network errors — return empty list
      _logger.e('[Chat] getMyRooms error: $e');
      return [];
    }
  }

  Future<List<ChatMessageEntity>> getMessages(String roomId) async {
    final response = await apiClient.get('/chats/rooms/$roomId/messages');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => _parseMessage(json))
            .toList();
      }
      return [];
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
      return _parseMessage(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to send message');
    }
  }

  ChatRoomEntity _parseRoom(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final List<ChatMessageEntity> messages = rawMessages is List
        ? rawMessages.whereType<Map<String, dynamic>>().map((m) => _parseMessage(m)).toList()
        : [];

    final rawLastMsg = json['lastMessage'];
    final ChatMessageEntity? lastMessage = rawLastMsg is Map<String, dynamic>
        ? _parseMessage(rawLastMsg)
        : (messages.isNotEmpty ? messages.last : null);

    return ChatRoomEntity(
      id: json['id']?.toString() ?? '',
      participantA: json['participantA']?.toString() ?? '',
      participantB: json['participantB']?.toString() ?? '',
      contextType: json['contextType']?.toString(),
      contextId: json['contextId']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      userA: json['userA'] is Map ? json['userA'] as Map<String, dynamic> : {},
      userB: json['userB'] is Map ? json['userB'] as Map<String, dynamic> : {},
      messages: messages,
      lastMessage: lastMessage,
      unreadCount: (json['unreadCount'] as int?) ?? 0,
    );
  }

  ChatMessageEntity _parseMessage(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}

