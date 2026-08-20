import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/retailer_dashboard_use_cases.dart';
import 'retailer_dashboard_event.dart';
import 'retailer_dashboard_state.dart';

class RetailerDashboardBloc extends Bloc<RetailerDashboardEvent, RetailerDashboardState> {
  final GetMyShopUseCase _getMyShopUseCase;
  final CreateShopUseCase _createShopUseCase;
  final UpdateShopUseCase _updateShopUseCase;
  final GetShopAnalyticsUseCase _getShopAnalyticsUseCase;

  RetailerDashboardBloc({
    required GetMyShopUseCase getMyShopUseCase,
    required CreateShopUseCase createShopUseCase,
    required UpdateShopUseCase updateShopUseCase,
    required GetShopAnalyticsUseCase getShopAnalyticsUseCase,
  })  : _getMyShopUseCase = getMyShopUseCase,
        _createShopUseCase = createShopUseCase,
        _updateShopUseCase = updateShopUseCase,
        _getShopAnalyticsUseCase = getShopAnalyticsUseCase,
        super(const RetailerDashboardInitial()) {
    on<GetMyShopRequested>(_onGetMyShopRequested);
    on<GetShopAnalyticsRequested>(_onGetShopAnalyticsRequested);
    on<CreateShopRequested>(_onCreateShopRequested);
    on<UpdateShopRequested>(_onUpdateShopRequested);
  }

  Future<void> _onGetMyShopRequested(GetMyShopRequested event, Emitter<RetailerDashboardState> emit) async {
    final current = state is RetailerDashboardLoaded ? state as RetailerDashboardLoaded : const RetailerDashboardLoaded();
    emit(current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _getMyShopUseCase.execute();
    result.fold(
      (failure) => emit(current.copyWith(isLoading: false, failure: failure)),
      (shop) => emit(current.copyWith(isLoading: false, shop: shop)),
    );
  }

  Future<void> _onGetShopAnalyticsRequested(GetShopAnalyticsRequested event, Emitter<RetailerDashboardState> emit) async {
    final current = state is RetailerDashboardLoaded ? state as RetailerDashboardLoaded : const RetailerDashboardLoaded();
    emit(current.copyWith(isLoading: true, failure: null));
    final result = await _getShopAnalyticsUseCase.execute();
    result.fold(
      (failure) => emit(current.copyWith(isLoading: false, failure: failure)),
      (analytics) => emit(current.copyWith(isLoading: false, analytics: analytics)),
    );
  }

  Future<void> _onCreateShopRequested(CreateShopRequested event, Emitter<RetailerDashboardState> emit) async {
    final current = state is RetailerDashboardLoaded ? state as RetailerDashboardLoaded : const RetailerDashboardLoaded();
    emit(current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _createShopUseCase.execute(event.data);
    result.fold(
      (failure) => emit(current.copyWith(isLoading: false, failure: failure)),
      (shop) => emit(current.copyWith(isLoading: false, shop: shop, isSuccess: true)),
    );
  }

  Future<void> _onUpdateShopRequested(UpdateShopRequested event, Emitter<RetailerDashboardState> emit) async {
    final current = state is RetailerDashboardLoaded ? state as RetailerDashboardLoaded : const RetailerDashboardLoaded();
    emit(current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _updateShopUseCase.execute(event.data);
    result.fold(
      (failure) => emit(current.copyWith(isLoading: false, failure: failure)),
      (shop) => emit(current.copyWith(isLoading: false, shop: shop, isSuccess: true)),
    );
  }
}
