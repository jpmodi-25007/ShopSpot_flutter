class ApiConstants {
  static const String baseUrl = 'http://192.168.0.38:3001/api/v1'; // Dev endpoint
  static const String webBaseUrl = 'https://shopspot.local'; // Web and Deep Linking base URL
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.shopspot.app'; // Dummy Play Store link
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
