import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.0.38:3001/api/v1';
  static String get webBaseUrl => dotenv.env['WEB_BASE_URL'] ?? 'https://shopspot.local';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.shopspot.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/id1234567890'; // Dummy App Store link
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';

  // Orders endpoints
  static const String orders = '/orders';
}
