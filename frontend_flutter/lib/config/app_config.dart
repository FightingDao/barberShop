/// 环境枚举
enum Environment {
  development,
  testing,
  production,
}

/// App配置文件
class AppConfig {
  // 当前环境 - 可以通过编译参数传入或在这里手动修改
  static const String _envString = String.fromEnvironment(
    'ENV',
    defaultValue: 'development', // 默认为开发环境
  );

  /// 获取当前环境
  static Environment get environment {
    switch (_envString) {
      case 'production':
        return Environment.production;
      case 'testing':
        return Environment.testing;
      case 'development':
      default:
        return Environment.development;
    }
  }

  /// 各环境的API基础地址配置
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        // 开发环境 - 本地服务器
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://10.96.144.225:4000',
        );
      case Environment.testing:
        // 测试环境 - 替换为你的测试服务器地址
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://qifu-barber-backend.onrender.com',
        );
      case Environment.production:
        // 生产环境 - 替换为你的生产服务器地址
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://qifu-barber-backend.onrender.com',
        );
    }
  }

  /// 判断是否为生产环境
  static bool get isProduction => environment == Environment.production;

  /// 判断是否为开发环境
  static bool get isDevelopment => environment == Environment.development;

  /// 判断是否为测试环境
  static bool get isTesting => environment == Environment.testing;

  /// 获取环境名称
  static String get environmentName {
    switch (environment) {
      case Environment.development:
        return '开发';
      case Environment.testing:
        return '测试';
      case Environment.production:
        return '生产';
    }
  }

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
