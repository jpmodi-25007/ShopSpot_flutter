import 'package:equatable/equatable.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

final class SearchProductsRequested extends ProductEvent {
  final String? query;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;
  final int? page;
  final int? limit;

  const SearchProductsRequested({
    this.query,
    this.lat,
    this.lng,
    this.radiusKm,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [
        query,
        lat,
        lng,
        radiusKm,
        categoryId,
        minPrice,
        maxPrice,
        sort,
        page,
        limit,
      ];
}

final class GetTrendingProductsRequested extends ProductEvent {
  final int limit;

  const GetTrendingProductsRequested({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

final class GetProductDetailRequested extends ProductEvent {
  final String id;

  const GetProductDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class GetPriceComparisonRequested extends ProductEvent {
  final String id;
  final double? lat;
  final double? lng;

  const GetPriceComparisonRequested(this.id, {this.lat, this.lng});

  @override
  List<Object?> get props => [id, lat, lng];
}
