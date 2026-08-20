import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final String role;
  final String? avatarUrl;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    required this.role,
    this.avatarUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, email, mobile, role, avatarUrl, isActive];
}
