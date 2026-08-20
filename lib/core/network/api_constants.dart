class ApiConstants {
  static const String baseUrl = 'http://10.76.18.81:3001/api/v1'; // Dev endpoint
  
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
