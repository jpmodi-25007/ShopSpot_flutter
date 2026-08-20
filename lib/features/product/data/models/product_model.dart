import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    super.categoryId,
    super.brand,
    super.images = const [],
    super.mrp,
    required super.sellingPrice,
    super.stockQuantity = 0,
    super.lowStockThreshold = 5,
    super.sku,
    super.barcode,
    required super.shopId,
    super.tags = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['categoryId']?.toString(),
      brand: json['brand']?.toString(),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mrp: json['mrp'] != null ? double.tryParse(json['mrp'].toString()) : null,
      sellingPrice: json['sellingPrice'] != null ? double.tryParse(json['sellingPrice'].toString()) ?? 0.0 : 0.0,
      stockQuantity: json['stockQuantity'] != null ? int.tryParse(json['stockQuantity'].toString()) ?? 0 : 0,
      lowStockThreshold: json['lowStockThreshold'] != null ? int.tryParse(json['lowStockThreshold'].toString()) ?? 5 : 5,
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      shopId: json['shopId']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'brand': brand,
      'images': images,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'sku': sku,
      'barcode': barcode,
      'shopId': shopId,
      'tags': tags,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      categoryId: categoryId,
      brand: brand,
      images: images,
      mrp: mrp,
      sellingPrice: sellingPrice,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      sku: sku,
      barcode: barcode,
      shopId: shopId,
      tags: tags,
    );
  }
}
