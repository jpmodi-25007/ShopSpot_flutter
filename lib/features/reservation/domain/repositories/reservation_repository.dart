import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/reservation_entity.dart';

abstract class ReservationRepository {
  Future<Either<Failure, List<ReservationEntity>>> getMyReservations();
}
