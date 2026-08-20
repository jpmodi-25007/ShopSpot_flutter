import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../../../core/error/failure.dart';

abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationsLoaded extends ReservationState {
  final List<ReservationEntity> reservations;

  const ReservationsLoaded(this.reservations);

  @override
  List<Object?> get props => [reservations];
}

class ReservationError extends ReservationState {
  final Failure failure;

  const ReservationError(this.failure);

  @override
  List<Object?> get props => [failure];
}
