import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class CreateOrGetRoomRequested extends ChatEvent {
  final String targetUserId;
  final String? contextType;
  final String? contextId;
  const CreateOrGetRoomRequested(this.targetUserId, {this.contextType, this.contextId});
  @override
  List<Object?> get props => [targetUserId, contextType, contextId];
}

class GetMessagesRequested extends ChatEvent {
  final String roomId;
  const GetMessagesRequested(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SendMessageRequested extends ChatEvent {
  final String roomId;
  final String content;
  const SendMessageRequested(this.roomId, this.content);
  @override
  List<Object?> get props => [roomId, content];
}

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomLoaded extends ChatState {
  final ChatRoomEntity room;
  final List<ChatMessageEntity> messages;
  const ChatRoomLoaded(this.room, this.messages);
  @override
  List<Object?> get props => [room, messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
