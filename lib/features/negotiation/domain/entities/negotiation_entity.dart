import 'negotiation_enums.dart';
import 'message_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../../shop/domain/entities/shop_entity.dart';

class NegotiationEntity {
  final String id;
  final String productId;
  final ProductEntity? product;
  final String shopId;
  final ShopEntity? shop;
  final String customerId;
  final double initialPrice;
  final double offeredPrice;
  final double? counterPrice;
  final double? finalPrice;
  final int counterRound;
  final NegotiationStatus status;
  final String? customerMessage;
  final String? shopkeeperMessage;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MessageEntity> messages;

  const NegotiationEntity({
    required this.id,
    required this.productId,
    this.product,
    required this.shopId,
    this.shop,
    required this.customerId,
    required this.initialPrice,
    required this.offeredPrice,
    this.counterPrice,
    this.finalPrice,
    required this.counterRound,
    required this.status,
    this.customerMessage,
    this.shopkeeperMessage,
    this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });
}
