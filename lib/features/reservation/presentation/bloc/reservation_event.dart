import 'package:equatable/equatable.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyReservations extends ReservationEvent {}

class CancelReservation extends ReservationEvent {
  final String reservationId;
  const CancelReservation(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

class RescheduleReservation extends ReservationEvent {
  final String reservationId;
  final DateTime newDateTime;
  const RescheduleReservation({required this.reservationId, required this.newDateTime});

  @override
  List<Object?> get props => [reservationId, newDateTime];
}
