import '../entities/negotiation_entity.dart';
import '../repositories/negotiation_repository.dart';

// Customer Use Cases
class StartNegotiationUseCase {
  final NegotiationRepository repository;
  StartNegotiationUseCase(this.repository);

  Future<NegotiationEntity> call(String productId, double offeredPrice, {String? message}) {
    return repository.startNegotiation(productId, offeredPrice, message: message);
  }
}

class GetMyNegotiationsUseCase {
  final NegotiationRepository repository;
  GetMyNegotiationsUseCase(this.repository);

  Future<List<NegotiationEntity>> call({int page = 1, int limit = 20}) {
    return repository.getMyNegotiations(page: page, limit: limit);
  }
}

class GetNegotiationDetailUseCase {
  final NegotiationRepository repository;
  GetNegotiationDetailUseCase(this.repository);

  Future<NegotiationEntity> call(String id) {
    return repository.getNegotiationDetail(id);
  }
}

class CounterOfferUseCase {
  final NegotiationRepository repository;
  CounterOfferUseCase(this.repository);

  Future<NegotiationEntity> call(String id, double counterPrice) {
    return repository.counterOffer(id, counterPrice);
  }
}

class AcceptDealUseCase {
  final NegotiationRepository repository;
  AcceptDealUseCase(this.repository);

  Future<NegotiationEntity> call(String id) {
    return repository.acceptDeal(id);
  }
}

class RejectDealUseCase {
  final NegotiationRepository repository;
  RejectDealUseCase(this.repository);

  Future<NegotiationEntity> call(String id) {
    return repository.rejectDeal(id);
  }
}

// Shopkeeper Use Cases
class GetShopNegotiationsUseCase {
  final NegotiationRepository repository;
  GetShopNegotiationsUseCase(this.repository);

  Future<List<NegotiationEntity>> call({String? status, int page = 1, int limit = 20}) {
    return repository.getShopNegotiations(status: status, page: page, limit: limit);
  }
}

class ShopkeeperCounterUseCase {
  final NegotiationRepository repository;
  ShopkeeperCounterUseCase(this.repository);

  Future<NegotiationEntity> call(String id, double counterPrice, {String? message}) {
    return repository.shopkeeperCounter(id, counterPrice, message: message);
  }
}

class ShopkeeperAcceptUseCase {
  final NegotiationRepository repository;
  ShopkeeperAcceptUseCase(this.repository);

  Future<NegotiationEntity> call(String id) {
    return repository.shopkeeperAccept(id);
  }
}

class ShopkeeperRejectUseCase {
  final NegotiationRepository repository;
  ShopkeeperRejectUseCase(this.repository);

  Future<NegotiationEntity> call(String id) {
    return repository.shopkeeperReject(id);
  }
}
