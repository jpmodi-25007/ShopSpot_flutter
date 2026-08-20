import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String emailOrPhone, String password, String role);
  Future<Either<Failure, UserEntity>> register(String name, String email, String password, String role);
  Future<Either<Failure, UserEntity>> checkSession();
  Future<Either<Failure, UserEntity>> updateProfile(String name);
  Future<Either<Failure, void>> logout();
}
