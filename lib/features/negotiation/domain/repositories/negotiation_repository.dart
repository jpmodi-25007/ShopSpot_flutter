import '../entities/negotiation_entity.dart';

abstract class NegotiationRepository {
  // Customer
  Future<NegotiationEntity> startNegotiation(String productId, double offeredPrice, {String? message});
  Future<List<NegotiationEntity>> getMyNegotiations({int page = 1, int limit = 20});
  Future<NegotiationEntity> getNegotiationDetail(String id);
  Future<NegotiationEntity> counterOffer(String id, double counterPrice);
  Future<NegotiationEntity> acceptDeal(String id);
  Future<NegotiationEntity> rejectDeal(String id);

  // Shopkeeper
  Future<List<NegotiationEntity>> getShopNegotiations({String? status, int page = 1, int limit = 20});
  Future<NegotiationEntity> shopkeeperCounter(String id, double counterPrice, {String? message});
  Future<NegotiationEntity> shopkeeperAccept(String id);
  Future<NegotiationEntity> shopkeeperReject(String id);
}
