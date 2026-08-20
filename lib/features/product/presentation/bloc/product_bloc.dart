import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_products_use_case.dart';
import '../../domain/usecases/get_trending_products_use_case.dart';
import '../../domain/usecases/get_product_detail_use_case.dart';
import '../../domain/usecases/get_price_comparison_use_case.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final SearchProductsUseCase _searchProductsUseCase;
  final GetTrendingProductsUseCase _getTrendingProductsUseCase;
  final GetProductDetailUseCase _getProductDetailUseCase;
  final GetPriceComparisonUseCase _getPriceComparisonUseCase;

  ProductBloc({
    required SearchProductsUseCase searchProductsUseCase,
    required GetTrendingProductsUseCase getTrendingProductsUseCase,
    required GetProductDetailUseCase getProductDetailUseCase,
    required GetPriceComparisonUseCase getPriceComparisonUseCase,
  })  : _searchProductsUseCase = searchProductsUseCase,
        _getTrendingProductsUseCase = getTrendingProductsUseCase,
        _getProductDetailUseCase = getProductDetailUseCase,
        _getPriceComparisonUseCase = getPriceComparisonUseCase,
        super(const ProductInitial()) {
    on<SearchProductsRequested>(_onSearchProductsRequested);
    on<GetTrendingProductsRequested>(_onGetTrendingProductsRequested);
    on<GetProductDetailRequested>(_onGetProductDetailRequested);
    on<GetPriceComparisonRequested>(_onGetPriceComparisonRequested);
  }

  Future<void> _onSearchProductsRequested(SearchProductsRequested event, Emitter<ProductState> emit) async {
    final isLoadMore = (event.page ?? 1) > 1;
    if (!isLoadMore) {
      emit(const ProductLoading());
    }

    final result = await _searchProductsUseCase.execute(
      query: event.query,
      lat: event.lat,
      lng: event.lng,
      radiusKm: event.radiusKm,
      categoryId: event.categoryId,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      sort: event.sort,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) {
        if (!isLoadMore) emit(ProductError(failure));
      },
      (products) {
        if (isLoadMore && state is ProductsLoaded) {
          final currentProducts = (state as ProductsLoaded).products;
          emit(ProductsLoaded(
            products: [...currentProducts, ...products],
            hasReachedMax: products.isEmpty || products.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        } else {
          emit(ProductsLoaded(
            products: products,
            hasReachedMax: products.isEmpty || products.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        }
      },
    );
  }

  Future<void> _onGetTrendingProductsRequested(GetTrendingProductsRequested event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    final result = await _getTrendingProductsUseCase.execute(event.limit);
    result.fold(
      (failure) => emit(ProductError(failure)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  Future<void> _onGetProductDetailRequested(GetProductDetailRequested event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    final result = await _getProductDetailUseCase.execute(event.id);
    result.fold(
      (failure) => emit(ProductError(failure)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  Future<void> _onGetPriceComparisonRequested(GetPriceComparisonRequested event, Emitter<ProductState> emit) async {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      final result = await _getPriceComparisonUseCase.execute(event.id, lat: event.lat, lng: event.lng);
      result.fold(
        (failure) => emit(ProductError(failure)),
        (comparisons) => emit(ProductDetailLoaded(product: currentState.product, comparisons: comparisons)),
      );
    } else {
      emit(const ProductLoading());
      // First get the product
      final productResult = await _getProductDetailUseCase.execute(event.id);
      await productResult.fold(
        (failure) async => emit(ProductError(failure)),
        (product) async {
          // Then get comparisons
          final comparisonResult = await _getPriceComparisonUseCase.execute(event.id, lat: event.lat, lng: event.lng);
          comparisonResult.fold(
            (failure) => emit(ProductError(failure)),
            (comparisons) => emit(ProductDetailLoaded(product: product, comparisons: comparisons)),
          );
        },
      );
    }
  }
}
