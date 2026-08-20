import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/negotiation_use_cases.dart';
import 'negotiation_event.dart';
import 'negotiation_state.dart';

class NegotiationBloc extends Bloc<NegotiationEvent, NegotiationState> {
  final StartNegotiationUseCase startNegotiation;
  final GetMyNegotiationsUseCase getMyNegotiations;
  final GetNegotiationDetailUseCase getNegotiationDetail;
  final CounterOfferUseCase counterOffer;
  final AcceptDealUseCase acceptDeal;
  final RejectDealUseCase rejectDeal;

  NegotiationBloc({
    required this.startNegotiation,
    required this.getMyNegotiations,
    required this.getNegotiationDetail,
    required this.counterOffer,
    required this.acceptDeal,
    required this.rejectDeal,
  }) : super(NegotiationInitial()) {
    on<GetMyNegotiationsRequested>(_onGetMyNegotiations);
    on<GetNegotiationDetailRequested>(_onGetNegotiationDetail);
    on<StartNegotiationRequested>(_onStartNegotiation);
    on<CounterOfferRequested>(_onCounterOffer);
    on<AcceptDealRequested>(_onAcceptDeal);
    on<RejectDealRequested>(_onRejectDeal);
  }

  Future<void> _onGetMyNegotiations(GetMyNegotiationsRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    final isLoadMore = event.page > 1;

    if (!isLoadMore) {
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(isSubmitting: true));
      } else {
        emit(NegotiationLoading());
      }
    }

    try {
      final negotiations = await getMyNegotiations(page: event.page, limit: event.limit);
      if (currentState is NegotiationLoaded) {
        if (isLoadMore) {
          final currentList = currentState.negotiations ?? [];
          emit(currentState.copyWith(
            negotiations: [...currentList, ...negotiations],
            isSubmitting: false,
            hasReachedMax: negotiations.isEmpty || negotiations.length < event.limit,
            currentPage: event.page,
          ));
        } else {
          emit(currentState.copyWith(
            negotiations: negotiations,
            isSubmitting: false,
            hasReachedMax: negotiations.isEmpty || negotiations.length < event.limit,
            currentPage: event.page,
          ));
        }
      } else {
        emit(NegotiationLoaded(
          negotiations: negotiations,
          hasReachedMax: negotiations.isEmpty || negotiations.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      if (!isLoadMore) emit(NegotiationError(e.toString()));
    }
  }

  Future<void> _onGetNegotiationDetail(GetNegotiationDetailRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    if (currentState is NegotiationLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    } else {
      emit(NegotiationLoading());
    }

    try {
      final detail = await getNegotiationDetail(event.id);
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: detail, isSubmitting: false));
      } else {
        emit(NegotiationLoaded(activeNegotiation: detail));
      }
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }

  Future<void> _onStartNegotiation(StartNegotiationRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    if (currentState is NegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await startNegotiation(event.productId, event.offeredPrice, message: event.message);
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(NegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }

  Future<void> _onCounterOffer(CounterOfferRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    if (currentState is NegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await counterOffer(event.id, event.counterPrice);
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(NegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }

  Future<void> _onAcceptDeal(AcceptDealRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    if (currentState is NegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await acceptDeal(event.id);
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(NegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }

  Future<void> _onRejectDeal(RejectDealRequested event, Emitter<NegotiationState> emit) async {
    final currentState = state;
    if (currentState is NegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await rejectDeal(event.id);
      if (currentState is NegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(NegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(NegotiationError(e.toString()));
    }
  }
}
