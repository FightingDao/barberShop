import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 认证状态管理Provider
/// 管理用户登录、注销等认证相关状态
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  User? get user => _currentUser; // 别名，方便使用
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  /// 初始化：检查本地存储的登录状态
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_authService.isLoggedIn()) {
        _currentUser = _authService.getCachedUser();
        _isLoggedIn = true;

        // 尝试从服务器更新用户信息
        await loadUser();
      }
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 手机号登录
  ///
  /// [phone] 手机号
  /// [password] 密码（可选）
  /// [code] 验证码（可选）
  /// 返回登录是否成功
  Future<bool> login(String phone, {String? password, String? code}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        phone: phone,
        password: password,
        code: code,
      );

      if (response != null) {
        _currentUser = response.user;
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = '登录失败，请重试';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 发送验证码
  ///
  /// [phone] 手机号
  /// 返回是否发送成功
  Future<bool> sendVerificationCode(String phone) async {
    try {
      return await _authService.sendVerificationCode(phone);
    } catch (e) {
      debugPrint('Send verification code error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 加载/刷新用户信息
  Future<void> loadUser() async {
    if (!_isLoggedIn) return;

    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load user error: $e');
    }
  }

  /// 更新用户信息
  ///
  /// [data] 要更新的用户数据
  /// 返回更新是否成功
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.updateProfile(data);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
