import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> searchProducts({
    String? query,
    double? lat,
    double? lng,
    double? radiusKm,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? limit,
  });

  Future<List<ProductModel>> getTrendingProducts(int limit);

  Future<ProductModel> getProductDetail(String id);

  Future<List<ProductModel>> getPriceComparison(String id, {double? lat, double? lng});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> searchProducts({
    String? query,
    double? lat,
    double? lng,
    double? radiusKm,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null) queryParams['q'] = query;
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (radiusKm != null) queryParams['radiusKm'] = radiusKm;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sort != null) queryParams['sort'] = sort;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await apiClient.get('/products/search', queryParameters: queryParams);
    final List<dynamic> data = response.data is List ? response.data : response.data['data'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getTrendingProducts(int limit) async {
    final response = await apiClient.get('/products/trending', queryParameters: {'limit': limit});
    final List<dynamic> data = response.data is List ? response.data : response.data['data'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductDetail(String id) async {
    final response = await apiClient.get('/products/$id');
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<List<ProductModel>> getPriceComparison(String id, {double? lat, double? lng}) async {
    final queryParams = <String, dynamic>{};
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;

    final response = await apiClient.get('/products/$id/compare', queryParameters: queryParams);
    final List<dynamic> data = response.data is List ? response.data : response.data['data'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
