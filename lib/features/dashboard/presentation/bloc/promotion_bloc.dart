import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/promotion_repository.dart';
import 'promotion_event.dart';
import 'promotion_state.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final PromotionRepository repository;

  PromotionBloc({required this.repository}) : super(const PromotionInitial()) {
    on<GetPromotionsRequested>(_onGetPromotionsRequested);
  }

  Future<void> _onGetPromotionsRequested(
    GetPromotionsRequested event,
    Emitter<PromotionState> emit,
  ) async {
    emit(const PromotionLoading());
    try {
      final banners = await repository.getActivePromotions();
      emit(PromotionsLoaded(banners: banners));
    } catch (e) {
      emit(PromotionError(message: e.toString()));
    }
  }
}
