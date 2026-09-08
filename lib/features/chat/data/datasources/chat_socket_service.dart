import 'dart:async';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/chat_entity.dart';

class ChatSocketService {
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  io.Socket? _socket;
  final StreamController<ChatMessageEntity> _messageController =
      StreamController<ChatMessageEntity>.broadcast();

  bool _isConnected = false;

  ChatSocketService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Stream<ChatMessageEntity> get messages => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String roomId) async {
    if (_isConnected) {
      _joinRoom(roomId);
      return;
    }

    final token = await _secureStorage.read('accessToken');

    _socket = io.io(
      'https://findivo-backend.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token ?? ''})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _logger.i('[Chat Socket] Connected');
      _isConnected = true;
      _joinRoom(roomId);
    });

    _socket!.onDisconnect((_) {
      _logger.w('[Chat Socket] Disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((data) {
      _logger.e('[Chat Socket] Connect error: $data');
    });

    _socket!.on('newMessage', (data) {
      try {
        final msg = _parseSocketMessage(data as Map<String, dynamic>);
        _messageController.add(msg);
      } catch (e) {
        _logger.e('[Chat Socket] Failed to parse message: $e');
      }
    });

    _socket!.connect();
  }

  void _joinRoom(String roomId) {
    _socket?.emit('joinRoom', {'roomId': roomId});
    _logger.i('[Chat Socket] Joined room: $roomId');
  }

  void sendMessage(String roomId, String content) {
    if (!_isConnected) {
      _logger.w('[Chat Socket] Cannot send: not connected');
      return;
    }
    _socket?.emit('sendMessage', {'roomId': roomId, 'content': content});
  }

  void leaveRoom(String roomId) {
    _socket?.emit('leaveRoom', {'roomId': roomId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _logger.i('[Chat Socket] Disconnected and disposed');
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }

  ChatMessageEntity _parseSocketMessage(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: json['roomId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
