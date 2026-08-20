import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/saved_use_cases.dart';
import 'saved_event.dart';
import 'saved_state.dart';

class SavedBloc extends Bloc<SavedEvent, SavedState> {
  final GetSavedProductsUseCase _getSavedProducts;
  final SaveProductUseCase _saveProduct;
  final RemoveSavedProductUseCase _removeSavedProduct;
  final GetSavedShopsUseCase _getSavedShops;
  final SaveShopUseCase _saveShop;
  final RemoveSavedShopUseCase _removeSavedShop;

  SavedBloc({
    required GetSavedProductsUseCase getSavedProducts,
    required SaveProductUseCase saveProduct,
    required RemoveSavedProductUseCase removeSavedProduct,
    required GetSavedShopsUseCase getSavedShops,
    required SaveShopUseCase saveShop,
    required RemoveSavedShopUseCase removeSavedShop,
  })  : _getSavedProducts = getSavedProducts,
        _saveProduct = saveProduct,
        _removeSavedProduct = removeSavedProduct,
        _getSavedShops = getSavedShops,
        _saveShop = saveShop,
        _removeSavedShop = removeSavedShop,
        super(const SavedInitial()) {
    on<GetSavedProductsRequested>(_onGetSavedProducts);
    on<SaveProductRequested>(_onSaveProduct);
    on<RemoveSavedProductRequested>(_onRemoveSavedProduct);
    on<GetSavedShopsRequested>(_onGetSavedShops);
    on<SaveShopRequested>(_onSaveShop);
    on<RemoveSavedShopRequested>(_onRemoveSavedShop);
  }

  SavedLoaded get _current => state is SavedLoaded ? state as SavedLoaded : const SavedLoaded();

  Future<void> _onGetSavedProducts(GetSavedProductsRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _getSavedProducts.execute();
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (products) => emit(_current.copyWith(isLoading: false, savedProducts: products)),
    );
  }

  Future<void> _onSaveProduct(SaveProductRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _saveProduct.execute(event.productId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetSavedProductsRequested());
      },
    );
  }

  Future<void> _onRemoveSavedProduct(RemoveSavedProductRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _removeSavedProduct.execute(event.productId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetSavedProductsRequested());
      },
    );
  }

  Future<void> _onGetSavedShops(GetSavedShopsRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _getSavedShops.execute();
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (shops) => emit(_current.copyWith(isLoading: false, savedShops: shops)),
    );
  }

  Future<void> _onSaveShop(SaveShopRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _saveShop.execute(event.shopId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetSavedShopsRequested());
      },
    );
  }

  Future<void> _onRemoveSavedShop(RemoveSavedShopRequested event, Emitter<SavedState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _removeSavedShop.execute(event.shopId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetSavedShopsRequested());
      },
    );
  }
}
