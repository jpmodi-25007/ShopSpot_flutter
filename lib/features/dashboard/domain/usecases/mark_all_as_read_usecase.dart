import '../repositories/notification_repository.dart';

class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<void> call() async {
    return repository.markAllAsRead();
  }
}
