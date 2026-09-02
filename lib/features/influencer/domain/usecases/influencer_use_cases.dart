import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/influencer_profile_entity.dart';
import '../entities/influencer_campaign_entity.dart';
import '../entities/influencer_bid_entity.dart';
import '../repositories/influencer_repository.dart';

class GetInfluencerProfileUseCase {
  final InfluencerRepository repository;
  GetInfluencerProfileUseCase(this.repository);
  Future<Either<Failure, InfluencerProfileEntity>> execute() => repository.getProfile();
}

class UpdateInfluencerProfileUseCase {
  final InfluencerRepository repository;
  UpdateInfluencerProfileUseCase(this.repository);
  Future<Either<Failure, InfluencerProfileEntity>> execute(Map<String, dynamic> data) =>
      repository.updateProfile(data);
}

class GetEligibleCampaignsUseCase {
  final InfluencerRepository repository;
  GetEligibleCampaignsUseCase(this.repository);
  Future<Either<Failure, List<InfluencerCampaignEntity>>> execute({int page = 1, int limit = 20, String? industry, String? search}) =>
      repository.getEligibleCampaigns(page: page, limit: limit, industry: industry, search: search);
}

class GetMyBidsUseCase {
  final InfluencerRepository repository;
  GetMyBidsUseCase(this.repository);
  Future<Either<Failure, List<InfluencerBidEntity>>> execute({int page = 1, int limit = 20}) => repository.getMyBids(page: page, limit: limit);
}

class SubmitBidUseCase {
  final InfluencerRepository repository;
  SubmitBidUseCase(this.repository);
  Future<Either<Failure, InfluencerBidEntity>> execute({
    required String campaignId,
    required Map<String, dynamic> data,
  }) =>
      repository.submitBid(campaignId: campaignId, data: data);
}
