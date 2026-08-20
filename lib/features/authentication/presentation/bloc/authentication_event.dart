import 'package:equatable/equatable.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

final class LoginSubmitted extends AuthenticationEvent {
  final String emailOrPhone;
  final String password;
  final String role;

  const LoginSubmitted({required this.emailOrPhone, required this.password, required this.role});

  @override
  List<Object?> get props => [emailOrPhone, password, role];
}

final class RegisterSubmitted extends AuthenticationEvent {
  final String emailOrPhone;
  final String password;
  final String role;
  final String name;

  const RegisterSubmitted({
    required this.emailOrPhone,
    required this.password,
    required this.role,
    required this.name,
  });

  @override
  List<Object?> get props => [emailOrPhone, password, role, name];
}

final class GuestLoginRequested extends AuthenticationEvent {
  const GuestLoginRequested();
}

final class LogoutRequested extends AuthenticationEvent {
  const LogoutRequested();
}

final class CheckSessionRequested extends AuthenticationEvent {
  const CheckSessionRequested();
}

class UpdateProfileRequested extends AuthenticationEvent {
  final String name;

  const UpdateProfileRequested({required this.name});

  @override
  List<Object> get props => [name];
}
