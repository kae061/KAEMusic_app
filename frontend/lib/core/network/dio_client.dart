import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../constants/api_endpoints.dart';
import '../utils/token_manager.dart';
import '../errors/app_exception.dart';

class DioClient {
  DioClient._();
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;

  late final Dio _dio = _createDio();

  Dio get dio => _dio;

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      _AuthInterceptor(dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('Adding Authorization header to ${options.method} ${options.path}');
      debugPrint('Token length: ${token.length}');
    } else {
      debugPrint('No access token found for ${options.method} ${options.path}');
    }

    final userId = await TokenManager.getValue(AppConstants.userIdKey);
    if (userId != null) {
      options.headers['X-User-Id'] = userId;
      debugPrint('Adding X-User-Id header to ${options.method} ${options.path}');
      debugPrint('User ID: $userId');
    } else {
      debugPrint('No userId found for ${options.method} ${options.path}');
    }

    if (options.data is FormData) {
      options.headers.remove('Content-Type');
    }
    debugPrint('Request headers: ${options.headers}');
    debugPrint('Full URL: ${options.uri}');
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint('Response status: ${response.statusCode} for ${response.requestOptions.path}');
    debugPrint('Response data: ${response.data}');
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('ERROR: ${err.type} for ${err.requestOptions.path}');
    debugPrint('ERROR Status: ${err.response?.statusCode}');
    debugPrint('ERROR Message: ${err.message}');
    debugPrint('ERROR Response: ${err.response?.data}');
    debugPrint('ERROR Headers: ${err.requestOptions.headers}');

    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.refresh)) {
      if (_isRefreshing) {
        _pendingRequests.add(_RetryRequest(err.requestOptions, handler));
        return;
      }
      _isRefreshing = true;
      try {
        final refreshToken = await TokenManager.getRefreshToken();
        if (refreshToken == null) {
          await TokenManager.clearTokens();
          handler.next(err);
          return;
        }
        final response = await _dio.post(
          ApiEndpoints.refresh,
          data: {'refreshToken': refreshToken},
        );
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        await TokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        // Retry original
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
        // Drain pending
        for (final req in _pendingRequests) {
          req.options.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            final res = await _dio.fetch(req.options);
            req.handler.resolve(res);
          } catch (e) {
            req.handler.next(DioException(requestOptions: req.options));
          }
        }
        _pendingRequests.clear();
      } catch (_) {
        await TokenManager.clearTokens();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _RetryRequest(this.options, this.handler);
}

AppException mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkException(message: 'Connection timed out. Check your internet.');
    case DioExceptionType.connectionError:
      return const NetworkException(message: 'No internet connection.');
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      final msg = e.response?.data?['message'] as String? ?? 'Something went wrong.';
      if (status == 401) return UnauthorizedException(message: msg);
      if (status == 404) return NotFoundException(message: msg);
      if (status == 422) {
        final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
        return ValidationException(
          message: msg,
          fieldErrors: errors?.map((k, v) => MapEntry(k, v.toString())),
        );
      }
      return ServerException(message: msg, statusCode: status);
    default:
      return AppException(message: e.message ?? 'An unexpected error occurred.');
  }
}
