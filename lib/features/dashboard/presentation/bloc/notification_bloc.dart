import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetMyNotificationsUseCase getMyNotifications;

  NotificationBloc({required this.getMyNotifications}) : super(NotificationInitial()) {
    on<GetMyNotificationsRequested>(_onGetMyNotifications);
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
}
