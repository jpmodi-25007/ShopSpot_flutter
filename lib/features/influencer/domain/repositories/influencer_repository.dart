import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/influencer_profile_entity.dart';
import '../entities/influencer_campaign_entity.dart';
import '../entities/influencer_bid_entity.dart';

abstract interface class InfluencerRepository {
  Future<Either<Failure, InfluencerProfileEntity>> getProfile();
  Future<Either<Failure, InfluencerProfileEntity>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, List<InfluencerCampaignEntity>>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry, String? search});
  Future<Either<Failure, List<InfluencerBidEntity>>> getMyBids({int page = 1, int limit = 20});
  Future<Either<Failure, InfluencerBidEntity>> submitBid({
    required String campaignId,
    required Map<String, dynamic> data,
  });
  Future<Either<Failure, void>> withdrawBid(String bidId);
  Future<Either<Failure, Map<String, dynamic>>> getInfluencerAnalytics();
}
