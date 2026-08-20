import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_public_shop_use_case.dart';
import '../../domain/usecases/get_shop_products_use_case.dart';
import '../../domain/usecases/get_nearby_shops_use_case.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetPublicShopUseCase _getPublicShopUseCase;
  final GetShopProductsUseCase _getShopProductsUseCase;
  final GetNearbyShopsUseCase _getNearbyShopsUseCase;

  ShopBloc({
    required GetPublicShopUseCase getPublicShopUseCase,
    required GetShopProductsUseCase getShopProductsUseCase,
    required GetNearbyShopsUseCase getNearbyShopsUseCase,
  })  : _getPublicShopUseCase = getPublicShopUseCase,
        _getShopProductsUseCase = getShopProductsUseCase,
        _getNearbyShopsUseCase = getNearbyShopsUseCase,
        super(const ShopInitial()) {
    on<GetPublicShopRequested>(_onGetPublicShopRequested);
    on<GetShopProductsRequested>(_onGetShopProductsRequested);
    on<GetNearbyShopsRequested>(_onGetNearbyShopsRequested);
  }

  Future<void> _onGetPublicShopRequested(GetPublicShopRequested event, Emitter<ShopState> emit) async {
    final currentState = state is ShopStateLoaded ? state as ShopStateLoaded : const ShopStateLoaded();
    emit(currentState.copyWith(isLoading: true, failure: null));
    
    final result = await _getPublicShopUseCase.execute(event.id);
    result.fold(
      (failure) => emit(currentState.copyWith(isLoading: false, failure: failure)),
      (shop) => emit(currentState.copyWith(isLoading: false, shop: shop)),
    );
  }

  Future<void> _onGetShopProductsRequested(GetShopProductsRequested event, Emitter<ShopState> emit) async {
    final currentState = state is ShopStateLoaded ? state as ShopStateLoaded : const ShopStateLoaded();
    emit(currentState.copyWith(isLoading: true, failure: null));
    
    final result = await _getShopProductsUseCase.execute(
      id: event.id,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(currentState.copyWith(isLoading: false, failure: failure)),
      (products) => emit(currentState.copyWith(isLoading: false, products: products)),
    );
  }

  Future<void> _onGetNearbyShopsRequested(GetNearbyShopsRequested event, Emitter<ShopState> emit) async {
    final currentState = state is ShopStateLoaded ? state as ShopStateLoaded : const ShopStateLoaded();
    emit(currentState.copyWith(isLoading: true, failure: null));
    
    final result = await _getNearbyShopsUseCase.execute(
      lat: event.lat,
      lng: event.lng,
      radiusKm: event.radiusKm,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(currentState.copyWith(isLoading: false, failure: failure)),
      (shops) => emit(currentState.copyWith(isLoading: false, nearbyShops: shops)),
    );
  }
}
