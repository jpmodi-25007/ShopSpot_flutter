import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../negotiation/domain/usecases/negotiation_use_cases.dart';
import 'retailer_negotiation_event.dart';
import 'retailer_negotiation_state.dart';

class RetailerNegotiationBloc extends Bloc<RetailerNegotiationEvent, RetailerNegotiationState> {
  final GetShopNegotiationsUseCase getShopNegotiations;
  final ShopkeeperCounterUseCase shopkeeperCounter;
  final ShopkeeperAcceptUseCase shopkeeperAccept;
  final ShopkeeperRejectUseCase shopkeeperReject;

  RetailerNegotiationBloc({
    required this.getShopNegotiations,
    required this.shopkeeperCounter,
    required this.shopkeeperAccept,
    required this.shopkeeperReject,
  }) : super(RetailerNegotiationInitial()) {
    on<GetShopNegotiationsRequested>(_onGetShopNegotiations);
    on<ShopkeeperCounterRequested>(_onShopkeeperCounter);
    on<ShopkeeperAcceptRequested>(_onShopkeeperAccept);
    on<ShopkeeperRejectRequested>(_onShopkeeperReject);
  }

  Future<void> _onGetShopNegotiations(GetShopNegotiationsRequested event, Emitter<RetailerNegotiationState> emit) async {
    final currentState = state;
    if (currentState is RetailerNegotiationLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    } else {
      emit(RetailerNegotiationLoading());
    }

    try {
      final negotiations = await getShopNegotiations(status: event.status, page: event.page, limit: event.limit);
      if (currentState is RetailerNegotiationLoaded) {
        emit(currentState.copyWith(negotiations: negotiations, isSubmitting: false));
      } else {
        emit(RetailerNegotiationLoaded(negotiations: negotiations));
      }
    } catch (e) {
      emit(RetailerNegotiationError(e.toString()));
    }
  }

  Future<void> _onShopkeeperCounter(ShopkeeperCounterRequested event, Emitter<RetailerNegotiationState> emit) async {
    final currentState = state;
    if (currentState is RetailerNegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await shopkeeperCounter(event.id, event.counterPrice, message: event.message);
      if (currentState is RetailerNegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(RetailerNegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(RetailerNegotiationError(e.toString()));
    }
  }

  Future<void> _onShopkeeperAccept(ShopkeeperAcceptRequested event, Emitter<RetailerNegotiationState> emit) async {
    final currentState = state;
    if (currentState is RetailerNegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await shopkeeperAccept(event.id);
      if (currentState is RetailerNegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(RetailerNegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(RetailerNegotiationError(e.toString()));
    }
  }

  Future<void> _onShopkeeperReject(ShopkeeperRejectRequested event, Emitter<RetailerNegotiationState> emit) async {
    final currentState = state;
    if (currentState is RetailerNegotiationLoaded) emit(currentState.copyWith(isSubmitting: true));

    try {
      final negotiation = await shopkeeperReject(event.id);
      if (currentState is RetailerNegotiationLoaded) {
        emit(currentState.copyWith(activeNegotiation: negotiation, isSubmitting: false));
      } else {
        emit(RetailerNegotiationLoaded(activeNegotiation: negotiation));
      }
    } catch (e) {
      emit(RetailerNegotiationError(e.toString()));
    }
  }
}
