import '../../../../core/network/api_client.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations();
}

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final ApiClient apiClient;

  ReservationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    final response = await apiClient.get('/reservations');
    final data = response.data['data'];
    if (data == null) return [];
    
    return (data as List)
        .map((json) => ReservationModel.fromJson(json))
        .toList();
  }
}
