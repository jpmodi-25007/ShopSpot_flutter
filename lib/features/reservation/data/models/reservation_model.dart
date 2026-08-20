import '../../domain/entities/reservation_entity.dart';

class ReservationModel extends ReservationEntity {
  const ReservationModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.shopName,
    required super.reservedPrice,
    required super.quantity,
    required super.status,
    required super.expiresAt,
    required super.qrCode,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['product']?['name'] as String? ?? 'Unknown Product',
      productImage: (json['product']?['images'] != null && (json['product']['images'] as List).isNotEmpty)
          ? json['product']['images'][0] as String
          : '',
      shopName: json['shop']?['name'] as String? ?? 'Unknown Shop',
      reservedPrice: _parseDouble(json['reservedPrice']),
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt']) ?? DateTime.now()
          : DateTime.now(),
      qrCode: json['qrCode'] as String? ?? '',
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
