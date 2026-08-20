import '../../domain/entities/negotiation_entity.dart';
import '../../domain/repositories/negotiation_repository.dart';
import '../datasources/negotiation_remote_data_source.dart';

class NegotiationRepositoryImpl implements NegotiationRepository {
  final NegotiationRemoteDataSource remoteDataSource;

  NegotiationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NegotiationEntity> startNegotiation(String productId, double offeredPrice, {String? message}) {
    return remoteDataSource.startNegotiation(productId, offeredPrice, message: message);
  }

  @override
  Future<List<NegotiationEntity>> getMyNegotiations({int page = 1, int limit = 20}) {
    return remoteDataSource.getMyNegotiations(page: page, limit: limit);
  }

  @override
  Future<NegotiationEntity> getNegotiationDetail(String id) {
    return remoteDataSource.getNegotiationDetail(id);
  }

  @override
  Future<NegotiationEntity> counterOffer(String id, double counterPrice) {
    return remoteDataSource.counterOffer(id, counterPrice);
  }

  @override
  Future<NegotiationEntity> acceptDeal(String id) {
    return remoteDataSource.acceptDeal(id);
  }

  @override
  Future<NegotiationEntity> rejectDeal(String id) {
    return remoteDataSource.rejectDeal(id);
  }

  @override
  Future<List<NegotiationEntity>> getShopNegotiations({String? status, int page = 1, int limit = 20}) {
    return remoteDataSource.getShopNegotiations(status: status, page: page, limit: limit);
  }

  @override
  Future<NegotiationEntity> shopkeeperCounter(String id, double counterPrice, {String? message}) {
    return remoteDataSource.shopkeeperCounter(id, counterPrice, message: message);
  }

  @override
  Future<NegotiationEntity> shopkeeperAccept(String id) {
    return remoteDataSource.shopkeeperAccept(id);
  }

  @override
  Future<NegotiationEntity> shopkeeperReject(String id) {
    return remoteDataSource.shopkeeperReject(id);
  }
}
