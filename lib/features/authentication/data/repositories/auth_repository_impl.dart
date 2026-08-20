import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String emailOrPhone, String password, String role) async {
    try {
      final response = await remoteDataSource.login(emailOrPhone, password, role);
      await secureStorage.write('accessToken', response.accessToken);
      if (response.refreshToken.isNotEmpty) {
        await secureStorage.write('refreshToken', response.refreshToken);
      }
      return Right(response.user.toEntity());
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String name, String emailOrPhone, String password, String role) async {
    try {
      final response = await remoteDataSource.register(name, emailOrPhone, password, role);
      await secureStorage.write('accessToken', response.accessToken);
      if (response.refreshToken.isNotEmpty) {
        await secureStorage.write('refreshToken', response.refreshToken);
      }
      return Right(response.user.toEntity());
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkSession() async {
    try {
      final token = await secureStorage.read('accessToken');
      if (token == null || token.isEmpty) {
        return Left(ServerFailure('No token found'));
      }
      final user = await remoteDataSource.getMe();
      return Right(user.toEntity());
    } on UnauthorizedException {
      await secureStorage.clear();
      return Left(ServerFailure('Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(String name) async {
    try {
      final user = await remoteDataSource.updateProfile(name);
      return Right(user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await secureStorage.clear();
      return const Right(null);
    } catch (e) {
      await secureStorage.clear();
      return const Right(null);
    }
  }
}
