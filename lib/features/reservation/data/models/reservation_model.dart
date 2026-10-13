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
      productImage: (() {
        final product = json['product'] as Map<String, dynamic>?;
        if (product == null) return '';
        final mediaAssets = product['mediaAssets'] as List?;
        if (mediaAssets != null && mediaAssets.isNotEmpty) {
          final first = mediaAssets[0];
          if (first is Map) {
            return (first['secureUrl'] ?? first['url'] ?? '').toString();
          }
          if (first is String) return first;
        }
        final images = product['images'] as List?;
        if (images != null && images.isNotEmpty) {
          final first = images[0];
          if (first is Map) {
            return (first['secureUrl'] ?? first['url'] ?? '').toString();
          }
          if (first is String) return first;
        }
        if (product['imageUrl'] != null) {
          return product['imageUrl'].toString();
        }
        return '';
      })(),
      shopName: json['shop']?['name'] as String? ?? 'Unknown Shop',
      reservedPrice: _parseDouble(json['reservedPrice']),
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt']) ?? DateTime.now()
          : DateTime.now(),
      qrCode: (json['qrToken'] as String?) ?? (json['qrCode'] as String?) ?? '',
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
