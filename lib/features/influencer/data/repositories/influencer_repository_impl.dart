import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/influencer_profile_entity.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import '../../domain/entities/influencer_bid_entity.dart';
import '../../domain/repositories/influencer_repository.dart';
import '../datasources/influencer_remote_data_source.dart';

class InfluencerRepositoryImpl implements InfluencerRepository {
  final InfluencerRemoteDataSource remoteDataSource;

  InfluencerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InfluencerProfileEntity>> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InfluencerProfileEntity>> updateProfile(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateProfile(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InfluencerCampaignEntity>>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry, String? search}) async {
    try {
      final campaigns = await remoteDataSource.getEligibleCampaigns(page: page, limit: limit, industry: industry, search: search);
      return Right(campaigns.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InfluencerBidEntity>>> getMyBids({int page = 1, int limit = 20}) async {
    try {
      final models = await remoteDataSource.getMyBids(page: page, limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InfluencerBidEntity>> submitBid({
    required String campaignId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final model = await remoteDataSource.submitBid(
        campaignId: campaignId,
        data: data,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInfluencerAnalytics() async {
    try {
      final data = await remoteDataSource.getInfluencerAnalytics();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawBid(String bidId) async {
    try {
      await remoteDataSource.withdrawBid(bidId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
