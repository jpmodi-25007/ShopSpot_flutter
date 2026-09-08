import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<CreateOrGetRoomRequested>(_onCreateOrGetRoom);
    on<GetMessagesRequested>(_onGetMessages);
    on<SendMessageRequested>(_onSendMessage);
  }

  Future<void> _onCreateOrGetRoom(CreateOrGetRoomRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await repository.createOrGetRoom(event.targetUserId, contextType: event.contextType, contextId: event.contextId);
    await result.fold(
      (failure) async => emit(ChatError(failure)),
      (room) async {
        final messagesResult = await repository.getMessages(room.id);
        messagesResult.fold(
          (failure) => emit(ChatError(failure)),
          (messages) => emit(ChatRoomLoaded(room, messages)),
        );
      },
    );
  }

  Future<void> _onGetMessages(GetMessagesRequested event, Emitter<ChatState> emit) async {
    if (state is ChatRoomLoaded) {
      final currentState = state as ChatRoomLoaded;
      final result = await repository.getMessages(event.roomId);
      result.fold(
        (failure) => emit(ChatError(failure)),
        (messages) => emit(ChatRoomLoaded(currentState.room, messages)),
      );
    }
  }

  Future<void> _onSendMessage(SendMessageRequested event, Emitter<ChatState> emit) async {
    if (state is ChatRoomLoaded) {
      final currentState = state as ChatRoomLoaded;
      
      // Optimistic update
      // Skipping optimistic update for simplicity, waiting for actual backend response
      
      final result = await repository.sendMessage(event.roomId, event.content);
      result.fold(
        (failure) => emit(ChatError(failure)),
        (message) {
          final updatedMessages = List.of(currentState.messages)..add(message);
          emit(ChatRoomLoaded(currentState.room, updatedMessages));
        },
      );
    }
  }
}
