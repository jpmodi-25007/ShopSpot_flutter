import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class SavedRepository {
  Future<Either<Failure, List<dynamic>>> getSavedProducts();
  Future<Either<Failure, void>> saveProduct(String productId);
  Future<Either<Failure, void>> removeSavedProduct(String productId);

  Future<Either<Failure, List<dynamic>>> getSavedShops();
  Future<Either<Failure, void>> saveShop(String shopId);
  Future<Either<Failure, void>> removeSavedShop(String shopId);
}
