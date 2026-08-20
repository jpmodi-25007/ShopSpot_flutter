import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.mobile,
    required super.role,
    super.avatarUrl,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      avatarUrl: json['avatarUrl']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      mobile: mobile,
      role: role,
      avatarUrl: avatarUrl,
      isActive: isActive,
    );
  }
}
