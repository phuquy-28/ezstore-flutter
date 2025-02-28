import 'package:dio/dio.dart';
import 'package:ezstore_flutter/data/services/api_exception.dart';
import 'package:ezstore_flutter/data/models/api_response.dart';
import '../../config/constants.dart';
import 'dart:developer' as dev;
import 'shared_preference_service.dart';

class ApiService {
  late final Dio _dio;
  final SharedPreferenceService _preferenceService;

  ApiService(this._preferenceService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _handleRequest,
        onResponse: _handleResponse,
        onError: _handleInterceptorError,
      ),
    );
  }

  void _handleRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    dev.log(
      '${AppLogs.cyan}⤴ REQUEST: ${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\nData: ${options.data}${AppLogs.reset}',
      name: 'API',
    );

    final token = _preferenceService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _handleResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log(
      '${AppLogs.green}⤵ RESPONSE [${response.statusCode}] ${response.requestOptions.uri}\n'
      'Data: ${response.data}${AppLogs.reset}',
      name: 'API',
    );
    handler.next(response);
  }

  void _handleInterceptorError(
      DioException error, ErrorInterceptorHandler handler) {
    dev.log(
      '${AppLogs.red}⨉ ERROR [${error.response?.statusCode}] ${error.requestOptions.uri}\n'
      '${error.message}\n${error.response?.data}${AppLogs.reset}',
      name: 'API',
      error: error,
    );
    handler.next(error);
  }

  Future<T> request<T>({
    required String path,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        fromJson,
      );

      if (apiResponse.error != null) {
        throw ApiException(
          apiResponse.statusCode,
          apiResponse.error!,
        );
      }

      if (apiResponse.statusCode < 200 || apiResponse.statusCode >= 300) {
        throw ApiException(
          apiResponse.statusCode,
          apiResponse.message,
        );
      }

      if (apiResponse.data == null) {
        return null as T;
      }

      return apiResponse.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Kết nối tới server quá lâu');
        case DioExceptionType.badResponse:
          return ApiException(
            error.response?.statusCode ?? 500,
            error.response?.data?['message'] ?? 'Lỗi server',
          );
        case DioExceptionType.cancel:
          return RequestCancelledException('Yêu cầu đã bị hủy');
        default:
          return NetworkException('Lỗi kết nối mạng');
      }
    }
    return UnknownException('Đã có lỗi xảy ra');
  }

  // Helper methods
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<T> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<T> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<T> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
}
