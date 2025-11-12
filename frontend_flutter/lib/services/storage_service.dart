import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/models.dart';

/// 本地存储服务
/// 使用 shared_preferences 进行数据持久化
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  /// 获取单例实例
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// 初始化存储服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 确保已初始化
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// 保存认证令牌
  Future<bool> saveToken(String token) async {
    return await prefs.setString(AppConfig.tokenKey, token);
  }

  /// 获取认证令牌
  String? getToken() {
    return prefs.getString(AppConfig.tokenKey);
  }

  /// 删除认证令牌
  Future<bool> removeToken() async {
    return await prefs.remove(AppConfig.tokenKey);
  }

  /// 保存用户信息
  Future<bool> saveUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    return await prefs.setString(AppConfig.userKey, jsonStr);
  }

  /// 获取用户信息
  User? getUser() {
    final jsonStr = prefs.getString(AppConfig.userKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 删除用户信息
  Future<bool> removeUser() async {
    return await prefs.remove(AppConfig.userKey);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    return await prefs.clear();
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return getToken() != null;
  }

  /// 保存自定义数据
  Future<bool> saveString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 获取自定义字符串数据
  String? getString(String key) {
    return prefs.getString(key);
  }

  /// 保存自定义布尔值
  Future<bool> saveBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 获取自定义布尔值
  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// 保存自定义整数
  Future<bool> saveInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 获取自定义整数
  int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// 保存自定义浮点数
  Future<bool> saveDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// 获取自定义浮点数
  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// 删除自定义数据
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}
