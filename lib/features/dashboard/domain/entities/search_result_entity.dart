import 'package:equatable/equatable.dart';
import '../../../../features/shop/domain/entities/shop_entity.dart';
import '../../../../features/product/domain/entities/product_entity.dart';

class SearchCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? iconUrl;

  const SearchCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, slug, iconUrl];
}

class SearchResultEntity extends Equatable {
  final List<ShopEntity> shops;
  final List<ProductEntity> products;
  final List<SearchCategoryEntity> categories;

  const SearchResultEntity({
    required this.shops,
    required this.products,
    required this.categories,
  });

  @override
  List<Object?> get props => [shops, products, categories];
}
