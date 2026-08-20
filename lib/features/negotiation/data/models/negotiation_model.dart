import '../../domain/entities/negotiation_entity.dart';
import '../../domain/entities/negotiation_enums.dart';
import 'message_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../shop/data/models/shop_model.dart';

class NegotiationModel extends NegotiationEntity {
  const NegotiationModel({
    required super.id,
    required super.productId,
    super.product,
    required super.shopId,
    super.shop,
    required super.customerId,
    required super.initialPrice,
    required super.offeredPrice,
    super.counterPrice,
    super.finalPrice,
    required super.counterRound,
    required super.status,
    super.customerMessage,
    super.shopkeeperMessage,
    super.expiresAt,
    super.acceptedAt,
    required super.createdAt,
    required super.updatedAt,
    super.messages = const [],
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) {
    NegotiationStatus status = NegotiationStatus.PENDING;
    switch (json['status']) {
      case 'COUNTERED': status = NegotiationStatus.COUNTERED; break;
      case 'ACCEPTED': status = NegotiationStatus.ACCEPTED; break;
      case 'REJECTED': status = NegotiationStatus.REJECTED; break;
      case 'EXPIRED': status = NegotiationStatus.EXPIRED; break;
      default: status = NegotiationStatus.PENDING;
    }

    return NegotiationModel(
      id: json['id'],
      productId: json['productId'],
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
      shopId: json['shopId'],
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']).toEntity() : null,
      customerId: json['customerId'],
      initialPrice: (json['initialPrice'] ?? 0).toDouble(),
      offeredPrice: (json['offeredPrice'] ?? 0).toDouble(),
      counterPrice: json['counterPrice'] != null ? (json['counterPrice']).toDouble() : null,
      finalPrice: json['finalPrice'] != null ? (json['finalPrice']).toDouble() : null,
      counterRound: json['counterRound'] ?? 0,
      status: status,
      customerMessage: json['customerMessage'],
      shopkeeperMessage: json['shopkeeperMessage'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messages: json['messages'] != null 
          ? (json['messages'] as List).map((m) => MessageModel.fromJson(m)).toList()
          : [],
    );
  }
}
