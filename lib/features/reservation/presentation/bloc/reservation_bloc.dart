import 'package:flutter_bloc/flutter_bloc.dart';
import 'reservation_event.dart';
import 'reservation_state.dart';
import '../../domain/usecases/get_my_reservations_use_case.dart';
import '../../domain/repositories/reservation_repository.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetMyReservationsUseCase getMyReservationsUseCase;
  final ReservationRepository repository;

  ReservationBloc({
    required this.getMyReservationsUseCase,
    required this.repository,
  }) : super(ReservationInitial()) {
    on<FetchMyReservations>(_onFetchMyReservations);
    on<CancelReservation>(_onCancelReservation);
    on<RescheduleReservation>(_onRescheduleReservation);
  }

  Future<void> _onFetchMyReservations(FetchMyReservations event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await getMyReservationsUseCase.execute();
    result.fold(
      (failure) => emit(ReservationError(failure)),
      (reservations) => emit(ReservationsLoaded(reservations)),
    );
  }

  Future<void> _onCancelReservation(CancelReservation event, Emitter<ReservationState> emit) async {
    final result = await repository.cancelReservation(event.reservationId);
    result.fold(
      (failure) => emit(ReservationError(failure)),
      (_) {
        emit(const ReservationActionSuccess('Reservation cancelled.'));
        // Refresh the list
        add(FetchMyReservations());
      },
    );
  }

  Future<void> _onRescheduleReservation(RescheduleReservation event, Emitter<ReservationState> emit) async {
    final result = await repository.rescheduleReservation(event.reservationId, event.newDateTime);
    result.fold(
      (failure) => emit(ReservationError(failure)),
      (_) {
        emit(const ReservationActionSuccess('Reservation rescheduled!'));
        // Refresh the list
        add(FetchMyReservations());
      },
    );
  }
}

