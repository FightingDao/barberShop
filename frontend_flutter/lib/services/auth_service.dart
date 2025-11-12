import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 认证服务
/// 处理用户认证相关的API调用
class AuthService {
  final ApiService _api = ApiService.instance;
  final StorageService _storage = StorageService.instance;

  static AuthService? _instance;

  AuthService._();

  /// 获取单例实例
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  /// 手机号登录/注册
  ///
  /// [phone] 手机号
  /// [password] 密码（可选）
  /// [code] 验证码（可选，如果提供则使用验证码登录）
  /// 返回包含用户信息和token的响应
  Future<LoginResponse?> login({
    required String phone,
    String? password,
    String? code,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'phone': phone,
          if (password != null && password.isNotEmpty) 'password': password,
          if (code != null && code.isNotEmpty) 'code': code,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final loginData = LoginResponse.fromJson(response.data!);

        // 保存token和用户信息
        await _storage.saveToken(loginData.token);
        await _storage.saveUser(loginData.user);

        return loginData;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 发送验证码
  ///
  /// [phone] 手机号
  /// 返回是否发送成功
  Future<bool> sendVerificationCode(String phone) async {
    try {
      final response = await _api.post(
        '/api/v1/auth/send-code',
        data: {'phone': phone},
      );

      return response.success;
    } catch (e) {
      rethrow;
    }
  }

  /// 验证码验证
  ///
  /// [phone] 手机号
  /// [code] 验证码
  /// 返回验证后的token
  Future<String?> verifyCode({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _api.post<String>(
        '/api/v1/auth/verify',
        data: {
          'phone': phone,
          'code': code,
        },
        fromJson: (json) => json.toString(),
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户信息
  ///
  /// 返回当前登录用户的详细信息
  Future<User?> getProfile() async {
    try {
      final response = await _api.get<User>(
        '/api/v1/auth/profile',
        fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        // 更新本地存储的用户信息
        await _storage.saveUser(response.data!);
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新用户信息
  ///
  /// [data] 要更新的用户数据
  /// 返回更新后的用户信息
  Future<User?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.put<User>(
        '/api/v1/auth/profile',
        data: data,
        fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        // 更新本地存储的用户信息
        await _storage.saveUser(response.data!);
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 登出
  ///
  /// 清除本地存储的token和用户信息
  Future<bool> logout() async {
    try {
      await _api.post('/api/v1/auth/logout');

      // 清除本地存储
      await _storage.removeToken();
      await _storage.removeUser();

      return true;
    } catch (e) {
      // 即使API调用失败，也清除本地存储
      await _storage.removeToken();
      await _storage.removeUser();
      return true;
    }
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }

  /// 获取本地存储的用户信息
  User? getCachedUser() {
    return _storage.getUser();
  }

  /// 获取本地存储的token
  String? getToken() {
    return _storage.getToken();
  }
}

/// 登录响应数据模型
class LoginResponse {
  final User user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}
