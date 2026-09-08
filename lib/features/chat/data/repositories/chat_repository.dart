import 'package:dartz/dartz.dart';
import '../../domain/entities/chat_entity.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_service.dart';

class ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketService socketService;

  ChatRepository({required this.remoteDataSource, required this.socketService});

  Future<Either<String, ChatRoomEntity>> createOrGetRoom(String targetUserId, {String? contextType, String? contextId}) async {
    try {
      final result = await remoteDataSource.createOrGetRoom(targetUserId, contextType: contextType, contextId: contextId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ChatRoomEntity>>> getMyRooms() async {
    try {
      final result = await remoteDataSource.getMyRooms();
      return Right(result);
    } catch (e) {
      return Right([]); // Graceful fallback — never crash the rooms list
    }
  }

  Future<Either<String, List<ChatMessageEntity>>> getMessages(String roomId) async {
    try {
      final result = await remoteDataSource.getMessages(roomId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, ChatMessageEntity>> sendMessage(String roomId, String content) async {
    try {
      final result = await remoteDataSource.sendMessage(roomId, content);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Socket methods
  Future<void> connectSocket(String roomId) => socketService.connect(roomId);
  void sendSocketMessage(String roomId, String content) => socketService.sendMessage(roomId, content);
  void leaveRoom(String roomId) => socketService.leaveRoom(roomId);
  Stream<ChatMessageEntity> get socketMessages => socketService.messages;
  bool get isSocketConnected => socketService.isConnected;
}
