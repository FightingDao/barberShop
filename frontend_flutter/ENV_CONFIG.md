# 多环境配置说明

本项目支持三种运行环境：开发环境（development）、测试环境（testing）、生产环境（production）。

## 环境配置

环境配置位于 `lib/config/app_config.dart` 文件中。

### 各环境的默认API地址

- **开发环境**: `http://localhost:4000`
- **测试环境**: `https://test-api.yourapp.com` (需要替换为实际测试服务器地址)
- **生产环境**: `https://api.yourapp.com` (需要替换为实际生产服务器地址)

### 修改默认API地址

在 `app_config.dart` 文件的 `apiBaseUrl` getter 方法中修改对应环境的 `defaultValue`:

```dart
case Environment.testing:
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://你的测试服务器地址',
  );
```

## 运行不同环境

### 方法1: 通过命令行参数指定环境

#### 开发环境 (默认)
```bash
flutter run
# 或者明确指定
flutter run --dart-define=ENV=development
```

#### 测试环境
```bash
flutter run --dart-define=ENV=testing
```

#### 生产环境
```bash
flutter run --dart-define=ENV=production
```

#### 自定义API地址
```bash
flutter run --dart-define=ENV=production --dart-define=API_BASE_URL=https://custom-api.com
```

### 方法2: 打包不同环境的应用

#### Android APK

开发环境:
```bash
flutter build apk --dart-define=ENV=development
```

测试环境:
```bash
flutter build apk --dart-define=ENV=testing
```

生产环境:
```bash
flutter build apk --dart-define=ENV=production
```

#### iOS

开发环境:
```bash
flutter build ios --dart-define=ENV=development
```

测试环境:
```bash
flutter build ios --dart-define=ENV=testing
```

生产环境:
```bash
flutter build ios --dart-define=ENV=production
```

## 在代码中使用环境变量

```dart
import 'package:your_app/config/app_config.dart';

// 获取当前API地址
String apiUrl = AppConfig.apiBaseUrl;

// 检查当前环境
if (AppConfig.isDevelopment) {
  print('当前是开发环境');
}

if (AppConfig.isProduction) {
  print('当前是生产环境');
}

// 获取环境名称
String envName = AppConfig.environmentName; // "开发"、"测试" 或 "生产"
```

## 配置 IDE 运行配置

### VS Code

在项目根目录创建或编辑 `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (开发环境)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=ENV=development"
      ]
    },
    {
      "name": "Flutter (测试环境)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=ENV=testing"
      ]
    },
    {
      "name": "Flutter (生产环境)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=ENV=production"
      ]
    }
  ]
}
```

### Android Studio / IntelliJ IDEA

1. 点击 Run → Edit Configurations
2. 点击 + 添加新配置
3. 选择 Flutter
4. 在 "Additional run args" 中填入: `--dart-define=ENV=testing`
5. 保存配置

## 注意事项

1. **安全性**: 不要在代码中硬编码敏感信息（如API密钥）。使用环境变量或安全存储方案。
2. **测试**: 在切换环境后，务必测试应用的各项功能。
3. **打包前检查**: 打包生产环境应用前，确认已修改为正确的生产服务器地址。
4. **热重载限制**: 修改 `const` 常量需要完全重启应用（hot restart），热重载（hot reload）不会生效。

## 常见问题

### Q: 为什么修改了环境配置但没有生效？

A: 环境配置使用的是编译时常量，需要完全重启应用。在开发时使用热重启（hot restart）而不是热重载（hot reload）。

### Q: 如何在安卓模拟器上连接本地服务器？

A:
- 使用 `10.0.2.2` 代替 `localhost`，例如: `http://10.0.2.2:4000`
- 或者使用电脑的局域网IP地址，例如: `http://192.168.1.100:4000`

### Q: 如何在iOS模拟器上连接本地服务器？

A: iOS模拟器可以直接使用 `localhost` 或 `127.0.0.1`。
