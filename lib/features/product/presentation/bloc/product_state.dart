import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product_entity.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final int currentPage;

  const ProductsLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax, currentPage];
}

final class ProductDetailLoaded extends ProductState {
  final ProductEntity product;
  final List<ProductEntity>? comparisons;

  const ProductDetailLoaded({required this.product, this.comparisons});

  @override
  List<Object?> get props => [product, comparisons];
}

final class ProductError extends ProductState {
  final Failure failure;

  const ProductError(this.failure);

  @override
  List<Object?> get props => [failure];
}
