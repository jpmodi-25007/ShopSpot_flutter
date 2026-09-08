import 'package:dartz/dartz.dart';
import '../../domain/entities/chat_entity.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepository({required this.remoteDataSource});

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
      return Left(e.toString());
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
}
