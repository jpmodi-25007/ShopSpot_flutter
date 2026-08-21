import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final _queuedRequests = <Map<String, dynamic>>[];

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final lastActiveStr = await _storage.read('lastActive');
    final now = DateTime.now();
    
    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      if (now.difference(lastActive).inDays >= 30) {
        // Session timeout
        await _storage.delete('accessToken');
        await _storage.delete('refreshToken');
        await _storage.delete('lastActive');
        return handler.reject(DioException(
          requestOptions: options,
          error: 'Session expired. Please login again.',
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 401),
        ));
      }
    }
    
    await _storage.write('lastActive', now.toIso8601String());

    final token = await _storage.read('accessToken');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read('refreshToken');
      
      if (refreshToken == null) {
        return handler.next(err);
      }

      final options = err.requestOptions;

      if (_isRefreshing) {
        _queuedRequests.add({
          'options': options,
          'handler': handler,
        });
        return;
      }

      _isRefreshing = true;

      try {
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));
        final response = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];

          await _storage.write('accessToken', newAccessToken);
          if (newRefreshToken != null) {
            await _storage.write('refreshToken', newRefreshToken);
          }

          options.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(options);
          handler.resolve(retryResponse);

          for (var request in _queuedRequests) {
            final reqOptions = request['options'] as RequestOptions;
            final reqHandler = request['handler'] as ErrorInterceptorHandler;
            reqOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            try {
              final res = await _dio.fetch(reqOptions);
              reqHandler.resolve(res);
            } on DioException catch (e) {
              reqHandler.next(e);
            }
          }
        } else {
          await _storage.delete('accessToken');
          await _storage.delete('refreshToken');
          handler.next(err);
        }
      } catch (e) {
        await _storage.delete('accessToken');
        await _storage.delete('refreshToken');
        handler.next(err);
      } finally {
        _isRefreshing = false;
        _queuedRequests.clear();
      }
    } else {
      handler.next(err);
    }
  }
}
