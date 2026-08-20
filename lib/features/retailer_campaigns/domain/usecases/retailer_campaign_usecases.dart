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
