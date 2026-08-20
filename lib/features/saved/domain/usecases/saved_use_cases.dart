import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/saved_repository.dart';

class GetSavedProductsUseCase {
  final SavedRepository repository;
  GetSavedProductsUseCase(this.repository);
  Future<Either<Failure, List<dynamic>>> execute() => repository.getSavedProducts();
}

class SaveProductUseCase {
  final SavedRepository repository;
  SaveProductUseCase(this.repository);
  Future<Either<Failure, void>> execute(String productId) => repository.saveProduct(productId);
}

class RemoveSavedProductUseCase {
  final SavedRepository repository;
  RemoveSavedProductUseCase(this.repository);
  Future<Either<Failure, void>> execute(String productId) => repository.removeSavedProduct(productId);
}

class GetSavedShopsUseCase {
  final SavedRepository repository;
  GetSavedShopsUseCase(this.repository);
  Future<Either<Failure, List<dynamic>>> execute() => repository.getSavedShops();
}

class SaveShopUseCase {
  final SavedRepository repository;
  SaveShopUseCase(this.repository);
  Future<Either<Failure, void>> execute(String shopId) => repository.saveShop(shopId);
}

class RemoveSavedShopUseCase {
  final SavedRepository repository;
  RemoveSavedShopUseCase(this.repository);
  Future<Either<Failure, void>> execute(String shopId) => repository.removeSavedShop(shopId);
}
