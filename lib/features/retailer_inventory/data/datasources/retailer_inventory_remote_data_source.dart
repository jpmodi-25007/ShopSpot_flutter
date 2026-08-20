import '../../../../core/network/api_client.dart';
import '../../../product/data/models/product_model.dart';

abstract interface class RetailerInventoryRemoteDataSource {
  Future<List<ProductModel>> getMyProducts({
    String? query,
    String? categoryId,
    String? stockStatus,
    int? page,
    int? limit,
  });

  Future<ProductModel> createProduct({
    required String name,
    required double sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  });

  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    double? sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  });

  Future<void> deleteProduct(String id);

  Future<ProductModel> updateStock({
    required String id,
    required int quantity,
  });

  Future<List<Map<String, dynamic>>> getSuppliers();
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getPurchaseOrders();
  Future<List<Map<String, dynamic>>> getStockHistory();
}

class RetailerInventoryRemoteDataSourceImpl implements RetailerInventoryRemoteDataSource {
  final ApiClient apiClient;

  RetailerInventoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getMyProducts({
    String? query,
    String? categoryId,
    String? stockStatus,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null) queryParams['q'] = query;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (stockStatus != null) queryParams['stockStatus'] = stockStatus;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await apiClient.get('/shopkeeper/products', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    required double sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'sellingPrice': sellingPrice,
    };
    if (description != null) data['description'] = description;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (brand != null) data['brand'] = brand;
    if (images != null) data['images'] = images;
    if (mrp != null) data['mrp'] = mrp;
    if (stockQuantity != null) data['stockQuantity'] = stockQuantity;
    if (lowStockThreshold != null) data['lowStockThreshold'] = lowStockThreshold;
    if (sku != null) data['sku'] = sku;
    if (barcode != null) data['barcode'] = barcode;
    if (tags != null) data['tags'] = tags;

    final response = await apiClient.post('/shopkeeper/products', data: data);
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    double? sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (sellingPrice != null) data['sellingPrice'] = sellingPrice;
    if (description != null) data['description'] = description;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (brand != null) data['brand'] = brand;
    if (images != null) data['images'] = images;
    if (mrp != null) data['mrp'] = mrp;
    if (stockQuantity != null) data['stockQuantity'] = stockQuantity;
    if (lowStockThreshold != null) data['lowStockThreshold'] = lowStockThreshold;
    if (sku != null) data['sku'] = sku;
    if (barcode != null) data['barcode'] = barcode;
    if (tags != null) data['tags'] = tags;

    final response = await apiClient.put('/shopkeeper/products/$id', data: data);
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await apiClient.delete('/shopkeeper/products/$id');
  }

  @override
  Future<ProductModel> updateStock({
    required String id,
    required int quantity,
  }) async {
    final response = await apiClient.put('/shopkeeper/products/$id/stock', data: {'quantity': quantity});
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final response = await apiClient.get('/shopkeeper/inventory/suppliers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    final response = await apiClient.post('/shopkeeper/inventory/suppliers', data: data);
    return response.data;
  }

  @override
  Future<List<Map<String, dynamic>>> getPurchaseOrders() async {
    final response = await apiClient.get('/shopkeeper/inventory/purchase-orders');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getStockHistory() async {
    final response = await apiClient.get('/shopkeeper/inventory/stock-history');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
