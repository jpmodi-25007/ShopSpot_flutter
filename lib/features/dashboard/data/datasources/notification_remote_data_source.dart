import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getMyNotifications();
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await apiClient.get('/notifications');
    // Backend returns: { data: [...], page, limit, total }
    final List<dynamic> items = response.data['data'] as List<dynamic>? ?? [];
    return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.post('/notifications/read-all');
  }
}
