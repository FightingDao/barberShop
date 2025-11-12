import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import 'storage_service.dart';

/// API服务基类
/// 提供统一的HTTP请求封装，包括请求/响应拦截器、错误处理等
class ApiService {
  late final Dio _dio;
  final StorageService _storage = StorageService.instance;

  static ApiService? _instance;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// 获取单例实例
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// 请求拦截器
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // 添加认证令牌
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 将请求数据的键名转换为snake_case
    if (options.data != null) {
      if (options.data is Map<String, dynamic>) {
        options.data = _convertKeysToSnake(options.data);
      }
    }

    // 将查询参数的键名转换为snake_case
    if (options.queryParameters.isNotEmpty) {
      options.queryParameters = _convertKeysToSnake(options.queryParameters);
    }

    handler.next(options);
  }

  /// 响应拦截器
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // 将响应数据的键名转换为camelCase
    if (response.data != null) {
      response.data = _convertKeysToCamel(response.data);
    }

    handler.next(response);
  }

  /// 错误拦截器
  void _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    // 统一错误处理
    if (error.response?.statusCode == 401) {
      // 清除令牌，跳转到登录页
      _storage.removeToken();
      _storage.removeUser();
      // 这里可以通过路由导航到登录页
      // 由于这是服务层，导航操作应该由上层处理
    }

    handler.next(error);
  }

  /// 将camelCase转换为snake_case
  String _toSnake(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// 将snake_case转换为camelCase
  String _toCamel(String str) {
    return str.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }

  /// 递归转换对象键名为snake_case
  dynamic _convertKeysToSnake(dynamic obj) {
    if (obj == null) {
      return obj;
    }
    if (obj is List) {
      return obj.map((e) => _convertKeysToSnake(e)).toList();
    } else if (obj is Map<String, dynamic>) {
      return obj.map((key, value) {
        final snakeKey = _toSnake(key);
        return MapEntry(snakeKey, _convertKeysToSnake(value));
      });
    }
    return obj;
  }

  /// 递归转换对象键名为camelCase
  dynamic _convertKeysToCamel(dynamic obj) {
    if (obj == null) {
      return obj;
    }
    if (obj is List) {
      return obj.map((e) => _convertKeysToCamel(e)).toList();
    } else if (obj is Map<String, dynamic>) {
      return obj.map((key, value) {
        final camelKey = _toCamel(key);
        return MapEntry(camelKey, _convertKeysToCamel(value));
      });
    }
    return obj;
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJson,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 处理错误
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = '网络请求失败';
    String code = 'UNKNOWN_ERROR';

    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        code = data['error']?['code'] ?? code;

        return ApiResponse<T>(
          success: false,
          message: message,
          error: ApiError(
            code: code,
            message: message,
            details: data['error']?['details'],
          ),
        );
      }
    }

    // 处理网络错误
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '请求超时，请检查网络连接';
        code = 'TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        message = '服务器响应错误';
        code = 'BAD_RESPONSE';
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        code = 'CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络设置';
        code = 'CONNECTION_ERROR';
        break;
      default:
        message = error.message ?? '未知错误';
        code = 'UNKNOWN_ERROR';
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      error: ApiError(
        code: code,
        message: message,
      ),
    );
  }

  /// 取消所有请求
  void cancelRequests() {
    _dio.close(force: true);
  }
}
