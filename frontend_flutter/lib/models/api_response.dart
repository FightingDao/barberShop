/// API响应通用包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

/// API错误信息
class ApiError {
  final String code;
  final String message;
  final dynamic details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'],
    );
  }
}

/// 分页响应
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
