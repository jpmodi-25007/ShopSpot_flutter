import '../../../../core/network/api_client.dart';

abstract class SavedRemoteDataSource {
  Future<List<dynamic>> getSavedProducts();
  Future<void> saveProduct(String productId);
  Future<void> removeSavedProduct(String productId);
  
  Future<List<dynamic>> getSavedShops();
  Future<void> saveShop(String shopId);
  Future<void> removeSavedShop(String shopId);
}

class SavedRemoteDataSourceImpl implements SavedRemoteDataSource {
  final ApiClient apiClient;

  SavedRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getSavedProducts() async {
    final response = await apiClient.get('/saved/products');
    return response.data['data'] as List<dynamic>? ?? [];
  }

  @override
  Future<void> saveProduct(String productId) async {
    await apiClient.post('/saved/products/$productId');
  }

  @override
  Future<void> removeSavedProduct(String productId) async {
    await apiClient.delete('/saved/products/$productId');
  }

  @override
  Future<List<dynamic>> getSavedShops() async {
    final response = await apiClient.get('/saved/shops');
    return response.data['data'] as List<dynamic>? ?? [];
  }

  @override
  Future<void> saveShop(String shopId) async {
    await apiClient.post('/saved/shops/$shopId');
  }

  @override
  Future<void> removeSavedShop(String shopId) async {
    await apiClient.delete('/saved/shops/$shopId');
  }
}
