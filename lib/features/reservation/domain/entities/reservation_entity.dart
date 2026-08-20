import 'package:equatable/equatable.dart';

class ReservationEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final String shopName;
  final double reservedPrice;
  final int quantity;
  final String status;
  final DateTime expiresAt;
  final String qrCode;

  const ReservationEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.shopName,
    required this.reservedPrice,
    required this.quantity,
    required this.status,
    required this.expiresAt,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        shopName,
        reservedPrice,
        quantity,
        status,
        expiresAt,
        qrCode,
      ];
}
