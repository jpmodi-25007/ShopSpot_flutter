class ServerException implements Exception {
  final String message;
  const ServerException([this.message = "A server error occurred."]);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = "A cache error occurred."]);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = "A network error occurred."]);
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = "Unauthorized access."]);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = "Validation failed."]);
}
