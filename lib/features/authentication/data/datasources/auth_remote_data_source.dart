import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String emailOrPhone, String password, String role);
  Future<AuthResponseModel> register(String name, String emailOrPhone, String password, String role);
  Future<UserModel> getMe();
  Future<UserModel> updateProfile(String name);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  AuthRemoteDataSourceImpl(this.apiClient, {required this.secureStorage});

  @override
  Future<AuthResponseModel> login(String emailOrPhone, String password, String role) async {
    final isEmail = emailOrPhone.contains('@');
    final endpoint = isEmail ? ApiConstants.login : '${ApiConstants.login}/mobile';

    final response = await apiClient.post(
      endpoint,
      data: {
        isEmail ? 'email' : 'mobile': emailOrPhone,
        'password': password,
        'role': role, // Already in SHOPKEEPER/CUSTOMER/INFLUENCER format
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(String name, String emailOrPhone, String password, String role) async {
    final isEmail = emailOrPhone.contains('@');
    final endpoint = isEmail ? ApiConstants.register : '${ApiConstants.register}/mobile';

    final response = await apiClient.post(
      endpoint,
      data: {
        'name': name,
        isEmail ? 'email' : 'mobile': emailOrPhone,
        'password': password,
        'role': role, // Already in SHOPKEEPER/CUSTOMER/INFLUENCER format
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await apiClient.get(ApiConstants.me);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateProfile(String name) async {
    final response = await apiClient.put(
      ApiConstants.me,
      data: {'name': name},
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // Backend requires refreshToken to revoke the session in the database
    final refreshToken = await secureStorage.read('refreshToken');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await apiClient.post(ApiConstants.logout, data: {'refreshToken': refreshToken});
      } catch (_) {
        // Logout failure is non-fatal — local session will still be cleared by the repository
      }
    }
  }
}
