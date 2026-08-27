import '../../../influencer/domain/entities/influencer_campaign_entity.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';
import '../repositories/retailer_campaign_repository.dart';

class CreateCampaignUseCase {
  final RetailerCampaignRepository repository;
  CreateCampaignUseCase(this.repository);

  Future<InfluencerCampaignEntity> call(CreateCampaignParams params) {
    return repository.createCampaign(params);
  }
}

class GetMyCampaignsUseCase {
  final RetailerCampaignRepository repository;
  GetMyCampaignsUseCase(this.repository);

  Future<List<InfluencerCampaignEntity>> call({int page = 1, int limit = 20}) {
    return repository.getMyCampaigns(page: page, limit: limit);
  }
}

class GetCampaignBidsUseCase {
  final RetailerCampaignRepository repository;
  GetCampaignBidsUseCase(this.repository);

  Future<List<InfluencerBidEntity>> call(String campaignId, {int page = 1, int limit = 20}) {
    return repository.getCampaignBids(campaignId, page: page, limit: limit);
  }
}

class AcceptBidUseCase {
  final RetailerCampaignRepository repository;
  AcceptBidUseCase(this.repository);

  Future<InfluencerBidEntity> call(String bidId) {
    return repository.acceptBid(bidId);
  }
}

class CounterBidUseCase {
  final RetailerCampaignRepository repository;
  CounterBidUseCase(this.repository);

  Future<InfluencerBidEntity> call(String bidId, double amount, {String? message}) {
    return repository.counterBid(bidId, amount, message: message);
  }
}

class UpdateCampaignUseCase {
  final RetailerCampaignRepository repository;
  UpdateCampaignUseCase(this.repository);

  Future<void> call(String campaignId, Map<String, dynamic> data) {
    return repository.updateCampaign(campaignId, data);
  }
}

class DeleteCampaignUseCase {
  final RetailerCampaignRepository repository;
  DeleteCampaignUseCase(this.repository);

  Future<void> call(String campaignId) {
    return repository.deleteCampaign(campaignId);
  }
}
