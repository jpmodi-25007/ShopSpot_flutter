import 'package:equatable/equatable.dart';

sealed class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

final class GetPublicShopRequested extends ShopEvent {
  final String id;

  const GetPublicShopRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class GetShopProductsRequested extends ShopEvent {
  final String id;
  final int page;
  final int limit;

  const GetShopProductsRequested({
    required this.id,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [id, page, limit];
}

final class GetNearbyShopsRequested extends ShopEvent {
  final double lat;
  final double lng;
  final double radiusKm;
  final String? categoryId;

  const GetNearbyShopsRequested({
    required this.lat,
    required this.lng,
    this.radiusKm = 5.0,
    this.categoryId,
  });

  @override
  List<Object?> get props => [lat, lng, radiusKm, categoryId];
}
