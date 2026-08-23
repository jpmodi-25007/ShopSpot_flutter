class ApiConstants {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.0.38:3001/api/v1');
  static const String webBaseUrl = String.fromEnvironment('WEB_BASE_URL', defaultValue: 'https://shopspot.local');
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
