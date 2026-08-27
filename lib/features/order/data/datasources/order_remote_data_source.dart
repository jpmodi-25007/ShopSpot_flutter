import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
  Future<List<ShopOrderModel>> getShopOrders();
  Future<void> updateOrderStatus(String orderId, String status);
}

class ShopOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String? customerEmail;
  final String? customerMobile;
  final List<dynamic> items;
  final double total;
  final String status;
  final String deliveryType;
  final DateTime createdAt;

  const ShopOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.customerEmail,
    this.customerMobile,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryType,
    required this.createdAt,
  });

  factory ShopOrderModel.fromJson(Map<String, dynamic> json) {
    return ShopOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customer']?['name'] as String? ?? 'Customer',
      customerEmail: json['customer']?['email'] as String?,
      customerMobile: json['customer']?['mobile'] as String?,
      items: json['items'] as List<dynamic>? ?? [],
      total: _parseDouble(json['total']),
      status: json['status'] as String? ?? 'PENDING',
      deliveryType: json['deliveryType'] as String? ?? 'STANDARD',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
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

  @override
  Future<List<ShopOrderModel>> getShopOrders() async {
    final response = await apiClient.get('/orders/shop');
    final data = response.data is List ? response.data : response.data['data'];
    if (data == null) return [];
    return (data as List).map((json) => ShopOrderModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await apiClient.patch('/orders/$orderId/status', data: {'status': status});
  }
}
