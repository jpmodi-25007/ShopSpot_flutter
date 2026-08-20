import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationRepository repository;

  GetMyNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call() {
    return repository.getMyNotifications();
  }
}
