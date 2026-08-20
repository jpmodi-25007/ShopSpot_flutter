import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.shopName,
    required super.shopLogoUrl,
    required super.items,
    required super.total,
    required super.status,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      shopName: json['shop']?['name'] as String? ?? 'Unknown Shop',
      shopLogoUrl: json['shop']?['logoUrl'] as String? ?? '',
      items: json['items'] as List<dynamic>? ?? [],
      total: _parseDouble(json['total']),
      status: json['status'] as String? ?? 'PENDING',
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

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      shopName: shopName,
      shopLogoUrl: shopLogoUrl,
      items: items,
      total: total,
      status: status,
      createdAt: createdAt,
    );
  }
}
