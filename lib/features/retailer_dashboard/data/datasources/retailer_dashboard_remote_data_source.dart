import '../../../../core/network/api_client.dart';
import '../../../shop/data/models/shop_model.dart';

abstract interface class RetailerDashboardRemoteDataSource {
  Future<ShopModel> getMyShop();
  Future<ShopModel> createShop(Map<String, dynamic> data);
  Future<ShopModel> updateShop(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getShopAnalytics();
}

class RetailerDashboardRemoteDataSourceImpl implements RetailerDashboardRemoteDataSource {
  final ApiClient apiClient;

  RetailerDashboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ShopModel> getMyShop() async {
    final response = await apiClient.get('/shopkeeper/shops');
    return ShopModel.fromJson(response.data);
  }

  @override
  Future<ShopModel> createShop(Map<String, dynamic> data) async {
    final response = await apiClient.post('/shopkeeper/shops', data: data);
    return ShopModel.fromJson(response.data);
  }

  @override
  Future<ShopModel> updateShop(Map<String, dynamic> data) async {
    final response = await apiClient.put('/shopkeeper/shops', data: data);
    return ShopModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getShopAnalytics() async {
    final response = await apiClient.get('/analytics/shop');
    return Map<String, dynamic>.from(response.data);
  }
}
