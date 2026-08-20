import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class GetMyReservationsUseCase {
  final ReservationRepository repository;

  GetMyReservationsUseCase(this.repository);

  Future<Either<Failure, List<ReservationEntity>>> execute() async {
    return await repository.getMyReservations();
  }
}
