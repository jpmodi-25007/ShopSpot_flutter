import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetMyNotificationsRequested extends NotificationEvent {
  const GetMyNotificationsRequested();
}
