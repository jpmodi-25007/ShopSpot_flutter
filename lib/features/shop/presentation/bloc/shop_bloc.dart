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

  ShopStateLoaded _loaded() =>
      state is ShopStateLoaded ? state as ShopStateLoaded : const ShopStateLoaded();

  Future<void> _onGetPublicShopRequested(GetPublicShopRequested event, Emitter<ShopState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null));

    final result = await _getPublicShopUseCase.execute(event.id);
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (shop) => emit(_loaded().copyWith(isLoading: false, shop: shop, failure: null)),
    );
  }

  Future<void> _onGetShopProductsRequested(GetShopProductsRequested event, Emitter<ShopState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null));

    final result = await _getShopProductsUseCase.execute(
      id: event.id,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (products) => emit(_loaded().copyWith(isLoading: false, products: products, failure: null)),
    );
  }

  Future<void> _onGetNearbyShopsRequested(GetNearbyShopsRequested event, Emitter<ShopState> emit) async {
    emit(_loaded().copyWith(isLoading: true, failure: null));

    final result = await _getNearbyShopsUseCase.execute(
      lat: event.lat,
      lng: event.lng,
      radiusKm: event.radiusKm,
      categoryId: event.categoryId,
    );
    result.fold(
      (failure) => emit(_loaded().copyWith(isLoading: false, failure: failure)),
      (shops) => emit(_loaded().copyWith(isLoading: false, nearbyShops: shops, failure: null)),
    );
  }
}
