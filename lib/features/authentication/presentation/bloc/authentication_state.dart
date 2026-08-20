import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

final class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

final class AuthenticationLoaded extends AuthenticationState {
  final UserEntity user;

  const AuthenticationLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthenticationGuest extends AuthenticationState {
  const AuthenticationGuest();
}

final class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}

final class AuthenticationError extends AuthenticationState {
  final Failure failure;

  const AuthenticationError(this.failure);

  @override
  List<Object?> get props => [failure];
}
