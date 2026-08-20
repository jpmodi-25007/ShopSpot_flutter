import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: { user: {...}, tokens: { accessToken, refreshToken, expiresIn } }
    final tokens = json['tokens'] as Map<String, dynamic>? ?? {};
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      accessToken: tokens['accessToken']?.toString() ?? '',
      refreshToken: tokens['refreshToken']?.toString() ?? '',
    );
  }
}
