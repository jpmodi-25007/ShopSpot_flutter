import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetMyNotificationsUseCase getMyNotifications;
  final MarkAllAsReadUseCase markAllAsRead;

  NotificationBloc({
    required this.getMyNotifications,
    required this.markAllAsRead,
  }) : super(NotificationInitial()) {
    on<GetMyNotificationsRequested>(_onGetMyNotifications);
    on<MarkAllAsReadRequested>(_onMarkAllAsRead);
  }

  Future<void> _onGetMyNotifications(GetMyNotificationsRequested event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await getMyNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(MarkAllAsReadRequested event, Emitter<NotificationState> emit) async {
    try {
      await markAllAsRead();
      add(const GetMyNotificationsRequested()); // Refresh
    } catch (e) {
      // Ignore error for now, or emit an error state
    }
  }
}
