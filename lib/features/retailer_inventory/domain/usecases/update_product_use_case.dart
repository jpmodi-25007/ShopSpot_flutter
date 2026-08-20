import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../repositories/retailer_inventory_repository.dart';

class UpdateProductUseCase {
  final RetailerInventoryRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> execute({
    required String id,
    String? name,
    double? sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  }) async {
    return await repository.updateProduct(
      id: id,
      name: name,
      sellingPrice: sellingPrice,
      description: description,
      categoryId: categoryId,
      brand: brand,
      images: images,
      mrp: mrp,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      sku: sku,
      barcode: barcode,
      tags: tags,
    );
  }
}
