import '../../domain/entities/search_result_entity.dart';
import '../../../../features/shop/data/models/shop_model.dart';
import '../../../../features/product/data/models/product_model.dart';

class SearchCategoryModel extends SearchCategoryEntity {
  const SearchCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.iconUrl,
  });

  factory SearchCategoryModel.fromJson(Map<String, dynamic> json) {
    return SearchCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      iconUrl: json['iconUrl'],
    );
  }

  SearchCategoryEntity toEntity() => SearchCategoryEntity(
        id: id,
        name: name,
        slug: slug,
        iconUrl: iconUrl,
      );
}

class SearchResultModel extends SearchResultEntity {
  const SearchResultModel({
    required super.shops,
    required super.products,
    required super.categories,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      shops: (json['shops'] as List?)?.map((e) => ShopModel.fromJson(e).toEntity()).toList() ?? [],
      products: (json['products'] as List?)?.map((e) => ProductModel.fromJson(e)).toList() ?? [],
      categories: (json['categories'] as List?)?.map((e) => SearchCategoryModel.fromJson(e).toEntity()).toList() ?? [],
    );
  }

  SearchResultEntity toEntity() => SearchResultEntity(
        shops: shops,
        products: products,
        categories: categories,
      );
}
