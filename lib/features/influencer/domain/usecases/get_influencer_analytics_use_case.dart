import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/influencer_repository.dart';

class GetInfluencerAnalyticsUseCase {
  final InfluencerRepository repository;

  GetInfluencerAnalyticsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute() {
    return repository.getInfluencerAnalytics();
  }
}
