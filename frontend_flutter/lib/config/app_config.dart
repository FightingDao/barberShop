/// App配置文件
class AppConfig {
  // API配置
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static const Duration apiTimeout = Duration(seconds: 10);

  // App信息
  static const String appName = '理发店预约';
  static const String appVersion = '1.0.0';

  // 本地存储Key
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';

  // 默认值
  static const int defaultPageSize = 20;
  static const double defaultRadius = 12.0;

  // 图片占位符
  static const String placeholderImage = 'assets/images/placeholder.png';
}
