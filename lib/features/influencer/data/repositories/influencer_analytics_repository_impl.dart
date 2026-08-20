import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/influencer_analytics_repository.dart';
import '../datasources/influencer_analytics_remote_data_source.dart';

class InfluencerAnalyticsRepositoryImpl implements InfluencerAnalyticsRepository {
  final InfluencerAnalyticsRemoteDataSource remoteDataSource;

  InfluencerAnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics() async {
    try {
      final data = await remoteDataSource.getAnalytics();
      return Right(data);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure(
          e.response?.data?['message'] ?? e.message ?? 'Server error occurred'
        ));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
