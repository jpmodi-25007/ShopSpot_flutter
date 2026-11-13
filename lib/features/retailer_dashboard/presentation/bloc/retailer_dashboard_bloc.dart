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

  RetailerDashboardLoaded _loaded() => state is RetailerDashboardLoaded
      ? state as RetailerDashboardLoaded
      : const RetailerDashboardLoaded();

  Future<void> _onGetMyShopRequested(GetMyShopRequested event, Emitter<RetailerDashboardState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _getMyShopUseCase.execute();
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (shop) => emit(_loaded().copyWith(isLoading: false, shop: shop, failure: null)),
    );
  }

  Future<void> _onGetShopAnalyticsRequested(GetShopAnalyticsRequested event, Emitter<RetailerDashboardState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null));
    final result = await _getShopAnalyticsUseCase.execute();
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (analytics) => emit(_loaded().copyWith(isLoading: false, analytics: analytics, failure: null)),
    );
  }

  Future<void> _onCreateShopRequested(CreateShopRequested event, Emitter<RetailerDashboardState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _createShopUseCase.execute(event.data);
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (shop) => emit(_loaded().copyWith(isLoading: false, shop: shop, isSuccess: true, failure: null)),
    );
  }

  Future<void> _onUpdateShopRequested(UpdateShopRequested event, Emitter<RetailerDashboardState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _updateShopUseCase.execute(event.data);
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (shop) => emit(_loaded().copyWith(isLoading: false, shop: shop, isSuccess: true, failure: null)),
    );
  }
}
