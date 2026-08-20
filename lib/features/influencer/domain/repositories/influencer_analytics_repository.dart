import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class InfluencerAnalyticsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics();
}
