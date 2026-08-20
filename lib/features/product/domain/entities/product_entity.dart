import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? brand;
  final List<String> images;
  final double? mrp;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? sku;
  final String? barcode;
  final String shopId;
  final List<String> tags;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.brand,
    this.images = const [],
    this.mrp,
    required this.sellingPrice,
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.sku,
    this.barcode,
    required this.shopId,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        brand,
        images,
        mrp,
        sellingPrice,
        stockQuantity,
        lowStockThreshold,
        sku,
        barcode,
        shopId,
        tags,
      ];
}
