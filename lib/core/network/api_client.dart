import 'package:dio/dio.dart';
import '../error/exceptions.dart';

abstract interface class ApiClient {
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers});
}

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient(this._dio);

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters, options: Options(headers: headers)));
  }

  @override
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    return _request(() => _dio.post(path, data: data, queryParameters: queryParameters, options: Options(headers: headers)));
  }

  @override
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    return _request(() => _dio.put(path, data: data, queryParameters: queryParameters, options: Options(headers: headers)));
  }

  @override
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    return _request(() => _dio.patch(path, data: data, queryParameters: queryParameters, options: Options(headers: headers)));
  }

  @override
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    return _request(() => _dio.delete(path, data: data, queryParameters: queryParameters, options: Options(headers: headers)));
  }

  Future<Response> _request(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw const UnauthorizedException();
        } else if (e.response!.statusCode == 422 || e.response!.statusCode == 400) {
          final dataMsg = e.response!.data['message'];
          final msg = dataMsg is List ? dataMsg.join(', ') : (dataMsg ?? 'Validation failed');
          throw ValidationException(msg.toString());
        }
        final dataMsg = e.response!.data['message'];
        final msg = dataMsg is List ? dataMsg.join(', ') : (dataMsg ?? 'Server error occurred');
        throw ServerException(msg.toString());
      } else {
        throw const NetworkException('Please check your internet connection.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
