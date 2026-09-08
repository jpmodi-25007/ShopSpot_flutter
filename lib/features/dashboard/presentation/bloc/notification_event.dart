import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetMyNotificationsRequested extends NotificationEvent {
  const GetMyNotificationsRequested();
}

class MarkAllAsReadRequested extends NotificationEvent {
  const MarkAllAsReadRequested();
}

class MarkNotificationAsReadRequested extends NotificationEvent {
  final String notificationId;
  const MarkNotificationAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
