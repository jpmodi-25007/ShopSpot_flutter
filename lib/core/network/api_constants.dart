import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    const dartDefine = String.fromEnvironment('BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    return dotenv.env['BASE_URL'] ?? 'https://findivo-backend.onrender.com/api/v1';
  }

  /// Origin (scheme + host + port) of the backend, used for the Socket.IO connection.
  static String get socketUrl {
    final uri = Uri.parse(baseUrl);
    return uri.replace(path: '', query: '', fragment: '').toString();
  }

  static String get webBaseUrl {
    const dartDefine = String.fromEnvironment('WEB_BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;
    return dotenv.env['WEB_BASE_URL'] ?? 'https://shopspot.local';
  }
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.shopspot.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/id1234567890'; // Dummy App Store link
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Orders endpoints
  static const String orders = '/orders';
}
