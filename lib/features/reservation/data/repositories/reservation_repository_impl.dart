import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_data_source.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReservationEntity>>> getMyReservations() async {
    try {
      final models = await remoteDataSource.getMyReservations();
      return Right(models);
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
