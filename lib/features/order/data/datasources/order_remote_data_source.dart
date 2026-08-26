import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getMyOrders() async {
    final response = await apiClient.get(ApiConstants.orders);
    final data = response.data is List ? response.data : response.data['data'];
    if (data == null) return [];
    
    return (data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }
}
