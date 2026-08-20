import 'package:flutter_bloc/flutter_bloc.dart';
import 'reservation_event.dart';
import 'reservation_state.dart';
import '../../domain/usecases/get_my_reservations_use_case.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetMyReservationsUseCase getMyReservationsUseCase;

  ReservationBloc({
    required this.getMyReservationsUseCase,
  }) : super(ReservationInitial()) {
    on<FetchMyReservations>(_onFetchMyReservations);
  }

  Future<void> _onFetchMyReservations(FetchMyReservations event, Emitter<ReservationState> emit) async {
    emit(ReservationLoading());
    final result = await getMyReservationsUseCase.execute();
    result.fold(
      (failure) => emit(ReservationError(failure)),
      (reservations) => emit(ReservationsLoaded(reservations)),
    );
  }
}
