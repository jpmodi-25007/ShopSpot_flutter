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
        String dataMsg = 'Server error occurred';
        if (e.response!.data is Map<String, dynamic> && e.response!.data['message'] != null) {
          final msgData = e.response!.data['message'];
          dataMsg = msgData is List ? msgData.join(', ') : msgData.toString();
        } else if (e.response!.data is String) {
          dataMsg = e.response!.data;
        }

        if (e.response!.statusCode == 401) {
          throw const UnauthorizedException();
        } else if (e.response!.statusCode == 422 || e.response!.statusCode == 400) {
          throw ValidationException(dataMsg);
        }
        throw ServerException(dataMsg);
      } else {
        throw const NetworkException('Please check your internet connection.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
