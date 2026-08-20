import '../../../../core/network/api_client.dart';
import '../models/shop_model.dart';
import '../../../product/data/models/product_model.dart';

abstract interface class ShopRemoteDataSource {
  Future<ShopModel> getPublicShop(String id);
  
  Future<List<ProductModel>> getShopProducts({
    required String id,
    int page = 1,
    int limit = 20,
  });

  Future<List<ShopModel>> getNearbyShops({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? categoryId,
  });
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final ApiClient apiClient;

  ShopRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ShopModel> getPublicShop(String id) async {
    final response = await apiClient.get('/shops/$id');
    return ShopModel.fromJson(response.data);
  }

  @override
  Future<List<ProductModel>> getShopProducts({
    required String id,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.get('/shops/$id/products', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ShopModel>> getNearbyShops({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? categoryId,
  }) async {
    final queryParams = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
    };
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }

    final response = await apiClient.get('/nearby/shops', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ShopModel.fromJson(json)).toList();
  }
}
