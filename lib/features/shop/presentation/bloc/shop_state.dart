import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

sealed class ShopState extends Equatable {
  final ShopEntity? shop;
  final List<ProductEntity>? products;
  final List<ShopEntity>? nearbyShops;
  final bool isLoading;
  final Failure? failure;

  const ShopState({
    this.shop,
    this.products,
    this.nearbyShops,
    this.isLoading = false,
    this.failure,
  });

  @override
  List<Object?> get props => [shop, products, nearbyShops, isLoading, failure];
}

final class ShopInitial extends ShopState {
  const ShopInitial();
}

final class ShopStateLoaded extends ShopState {
  const ShopStateLoaded({
    super.shop,
    super.products,
    super.nearbyShops,
    super.isLoading,
    super.failure,
  });

  ShopStateLoaded copyWith({
    ShopEntity? shop,
    List<ProductEntity>? products,
    List<ShopEntity>? nearbyShops,
    bool? isLoading,
    Failure? failure,
  }) {
    return ShopStateLoaded(
      shop: shop ?? this.shop,
      products: products ?? this.products,
      nearbyShops: nearbyShops ?? this.nearbyShops,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}
