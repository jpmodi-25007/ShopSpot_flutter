import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String shopName;
  final String shopLogoUrl;
  final List<dynamic> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.shopName,
    required this.shopLogoUrl,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        shopName,
        shopLogoUrl,
        items,
        total,
        status,
        createdAt,
      ];
}
