import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  StreamSubscription<dynamic>? _socketSubscription;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadChatRoomsRequested>(_onLoadRooms);
    on<CreateOrGetRoomRequested>(_onCreateOrGetRoom);
    on<ConnectSocketRequested>(_onConnectSocket);
    on<GetMessagesRequested>(_onGetMessages);
    on<SendMessageRequested>(_onSendMessage);
    on<SocketMessageReceived>(_onSocketMessageReceived);
  }

  Future<void> _onLoadRooms(LoadChatRoomsRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await repository.getMyRooms();
    result.fold(
      (failure) => emit(ChatRoomsLoaded([])), // Graceful empty list on error
      (rooms) => emit(ChatRoomsLoaded(rooms)),
    );
  }

  Future<void> _onCreateOrGetRoom(CreateOrGetRoomRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await repository.createOrGetRoom(
      event.targetUserId,
      contextType: event.contextType,
      contextId: event.contextId,
    );
    await result.fold(
      (failure) async => emit(ChatError(failure)),
      (room) async {
        final messagesResult = await repository.getMessages(room.id);
        messagesResult.fold(
          (failure) => emit(ChatRoomLoaded(room, [])),
          (messages) => emit(ChatRoomLoaded(room, messages)),
        );
        // Connect socket after room is established
        add(ConnectSocketRequested(room.id));
      },
    );
  }

  Future<void> _onConnectSocket(ConnectSocketRequested event, Emitter<ChatState> emit) async {
    await _socketSubscription?.cancel();
    await repository.connectSocket(event.roomId);
    _socketSubscription = repository.socketMessages.listen((message) {
      add(SocketMessageReceived(message));
    });
  }

  void _onSocketMessageReceived(SocketMessageReceived event, Emitter<ChatState> emit) {
    if (state is ChatRoomLoaded) {
      final current = state as ChatRoomLoaded;
      // Avoid duplicates (REST send + socket echo)
      final exists = current.messages.any((m) => m.id == event.message.id);
      if (!exists) {
        final updated = List.of(current.messages)..add(event.message);
        emit(ChatRoomLoaded(current.room, updated));
      }
    }
  }

  Future<void> _onGetMessages(GetMessagesRequested event, Emitter<ChatState> emit) async {
    if (state is ChatRoomLoaded) {
      final current = state as ChatRoomLoaded;
      final result = await repository.getMessages(event.roomId);
      result.fold(
        (failure) => null, // Silently fail, keep existing messages
        (messages) => emit(ChatRoomLoaded(current.room, messages)),
      );
    }
  }

  Future<void> _onSendMessage(SendMessageRequested event, Emitter<ChatState> emit) async {
    if (state is! ChatRoomLoaded) return;
    final current = state as ChatRoomLoaded;

    // Try socket first (real-time), fall back to REST
    if (repository.isSocketConnected) {
      repository.sendSocketMessage(event.roomId, event.content);
    } else {
      final result = await repository.sendMessage(event.roomId, event.content);
      result.fold(
        (failure) => emit(ChatError(failure)),
        (message) {
          final updated = List.of(current.messages)..add(message);
          emit(ChatRoomLoaded(current.room, updated));
        },
      );
    }
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    repository.leaveRoom('');
    return super.close();
  }
}
