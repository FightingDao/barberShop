# 理发店预约App - 打包部署指南

> 本文档详细介绍如何将 Flutter 项目打包成 Android APK/AAB 和 iOS IPA 应用

## 📋 目录

- [前置准备](#前置准备)
- [Android 打包](#android-打包)
  - [环境配置](#android-环境配置)
  - [配置应用信息](#配置应用信息)
  - [生成签名密钥](#生成签名密钥)
  - [构建 APK](#构建-apk)
  - [构建 AAB](#构建-aab)
- [iOS 打包](#ios-打包)
  - [环境配置](#ios-环境配置)
  - [配置证书](#配置证书)
  - [构建 IPA](#构建-ipa)
- [常见问题](#常见问题)

---

## 前置准备

### 1. 检查 Flutter 环境

```bash
flutter doctor
```

确保以下项目都显示 ✓：
- Flutter（必须）
- Android toolchain（打包 Android 需要）
- Xcode（打包 iOS 需要，仅 macOS）
- VS Code 或 Android Studio（必须）

### 2. 项目信息

- **应用名称**: 理发店预约
- **包名**: `com.barbershop.booking`
- **版本号**: 1.0.0+1
- **最低支持版本**:
  - Android: API 21 (Android 5.0)
  - iOS: 12.0

---

## Android 打包

### Android 环境配置

#### 步骤 1: 安装 Android Studio

1. 下载并安装 [Android Studio](https://developer.android.com/studio)
2. 打开 Android Studio
3. 进入 `Settings > Languages & Frameworks > Android SDK`
4. 安装以下组件：
   - Android SDK Platform（最新版本和 API 21+）
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools

#### 步骤 2: 配置 Android SDK 路径

查找 SDK 路径（通常在）：
- **macOS**: `/Users/你的用户名/Library/Android/sdk`
- **Windows**: `C:\Users\你的用户名\AppData\Local\Android\Sdk`
- **Linux**: `/home/你的用户名/Android/Sdk`

配置 Flutter 使用该 SDK：

```bash
flutter config --android-sdk /Users/你的用户名/Library/Android/sdk
```

#### 步骤 3: 接受 Android 许可

```bash
flutter doctor --android-licenses
```

输入 `y` 接受所有许可协议。

#### 步骤 4: 验证配置

```bash
flutter doctor
```

确保 "Android toolchain" 显示 ✓。

### 配置应用信息

#### 修改 Android 配置文件

编辑 `android/app/build.gradle`：

```gradle
android {
    namespace = "com.barbershop.booking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.barbershop.booking"  // 应用包名
        minSdk = 21                               // 最低支持 Android 5.0
        targetSdk = flutter.targetSdkVersion
        versionCode = 1                           // 版本号（整数）
        versionName = "1.0.0"                     // 版本名称（字符串）
    }
}
```

#### 配置应用名称和图标

1. **应用名称**: 编辑 `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="理发店预约"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

2. **应用图标**: 替换以下目录中的图标文件
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### 生成签名密钥

#### 步骤 1: 创建密钥库

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

按提示输入：
- 密钥库密码（至少 6 个字符）
- 姓名、组织等信息

**重要**: 请妥善保管密钥文件和密码！丢失后将无法更新应用！

#### 步骤 2: 配置签名

创建文件 `android/key.properties`：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=upload
storeFile=/Users/你的用户名/upload-keystore.jks
```

**注意**: 将 `key.properties` 添加到 `.gitignore`，避免泄露密钥！

#### 步骤 3: 在 build.gradle 中引用

编辑 `android/app/build.gradle`，在 `android {` 之前添加：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 构建 APK

#### Debug 版本（测试用）

```bash
cd /Users/zhangdi/work/barberShop/frontend_flutter
flutter build apk --debug
```

输出路径: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release 版本（正式发布）

```bash
flutter build apk --release
```

输出路径: `build/app/outputs/flutter-apk/app-release.apk`

#### 分 ABI 构建（减小体积）

```bash
flutter build apk --split-per-abi --release
```

会生成 3 个 APK（针对不同 CPU 架构）：
- `app-armeabi-v7a-release.apk` (32位 ARM)
- `app-arm64-v8a-release.apk` (64位 ARM)
- `app-x86_64-release.apk` (64位 x86)

### 构建 AAB

AAB (Android App Bundle) 是 Google Play 推荐的发布格式，体积更小。

```bash
flutter build appbundle --release
```

输出路径: `build/app/outputs/bundle/release/app-release.aab`

### 安装测试

#### 通过 ADB 安装

```bash
# 连接 Android 设备（USB 调试模式）
adb devices

# 安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### 直接运行到设备

```bash
flutter run --release
```

---

## iOS 打包

### iOS 环境配置

**注意**: iOS 打包仅支持 macOS 系统。

#### 步骤 1: 安装 Xcode

1. 从 App Store 下载并安装 [Xcode](https://apps.apple.com/app/xcode/id497799835)
2. 安装完成后，运行：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

3. 接受许可协议：

```bash
sudo xcodebuild -license accept
```

#### 步骤 2: 安装 CocoaPods

```bash
sudo gem install cocoapods
```

#### 步骤 3: 验证配置

```bash
flutter doctor
```

确保 "Xcode" 显示 ✓。

### 配置应用信息

#### 步骤 1: 在 Xcode 中打开项目

```bash
open ios/Runner.xcworkspace
```

#### 步骤 2: 配置 Bundle Identifier

1. 选择左侧 `Runner` 项目
2. 选择 `Runner` Target
3. 在 `General` 标签页：
   - **Display Name**: 理发店预约
   - **Bundle Identifier**: com.barbershop.booking
   - **Version**: 1.0.0
   - **Build**: 1

#### 步骤 3: 配置最低支持版本

在 `Deployment Info` 中：
- **Deployment Target**: iOS 12.0

#### 步骤 4: 配置应用图标

1. 准备 1024x1024 的 PNG 图标
2. 在 Xcode 中，点击 `Assets.xcassets` > `AppIcon`
3. 拖拽图标到对应尺寸

### 配置证书

#### 方案 A: 自动签名（推荐）

1. 在 Xcode 中选择 `Signing & Capabilities` 标签页
2. 勾选 `Automatically manage signing`
3. 选择你的 **Team**（需要 Apple Developer 账号）
4. Xcode 会自动创建和管理证书

#### 方案 B: 手动签名

需要在 [Apple Developer](https://developer.apple.com) 创建：
1. App ID
2. Development Certificate
3. Distribution Certificate
4. Provisioning Profile

详细步骤请参考 [Apple 官方文档](https://developer.apple.com/support/certificates/)。

### 构建 IPA

#### Debug 版本（模拟器测试）

```bash
flutter build ios --debug --simulator
```

#### Release 版本（真机测试）

```bash
flutter build ios --release
```

#### 生成 IPA（提交 App Store）

1. 在 Xcode 中，选择 `Product` > `Archive`
2. 等待归档完成
3. 在 Organizer 窗口中，选择归档记录
4. 点击 `Distribute App`
5. 选择分发方式：
   - **App Store Connect**: 提交到 App Store
   - **Ad Hoc**: 内部测试
   - **Enterprise**: 企业分发
   - **Development**: 开发测试

6. 按向导完成剩余步骤

#### 通过命令行生成 IPA

```bash
# 构建归档
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

# 导出 IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist exportOptions.plist
```

输出路径: `ios/build/ipa/Runner.ipa`

---

## 常见问题

### Android 问题

#### 1. Gradle 构建失败

**问题**: `FAILURE: Build failed with an exception.`

**解决**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

#### 2. SDK 版本不匹配

**问题**: `The plugin requires a higher Android gradle plugin version.`

**解决**: 更新 `android/build.gradle`：
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}
```

#### 3. 网络问题（国内）

**解决**: 配置国内镜像源，编辑 `android/build.gradle`：
```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'https://maven.aliyun.com/repository/public' }
    }
}
```

#### 4. 多dex问题

**问题**: `Cannot fit requested classes in a single dex file`

**解决**: 在 `android/app/build.gradle` 添加：
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### iOS 问题

#### 1. CocoaPods 安装失败

**解决**:
```bash
cd ios
pod repo update
pod install
```

#### 2. 签名错误

**问题**: `No profiles for 'com.barbershop.booking' were found`

**解决**: 在 Xcode 中重新配置签名，或检查 Bundle Identifier 是否正确。

#### 3. 最低版本不兼容

**问题**: 某些包要求更高的 iOS 版本

**解决**: 编辑 `ios/Podfile`，设置更高的版本：
```ruby
platform :ios, '13.0'
```

### 通用问题

#### 1. 依赖冲突

**解决**:
```bash
flutter clean
flutter pub get
```

#### 2. 构建缓存问题

**解决**:
```bash
flutter clean
cd android && ./gradlew clean && cd ..
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter pub get
```

---

## 📦 发布渠道

### Android

1. **Google Play**: 官方应用商店
   - 需要开发者账号（一次性 $25）
   - 上传 AAB 格式
   - 需要通过审核（通常 1-3 天）

2. **国内应用市场**:
   - 华为应用市场
   - 小米应用商店
   - OPPO软件商店
   - vivo应用商店
   - 应用宝（腾讯）
   - 豌豆荚
   - *上传 APK 格式，需要各自的开发者账号*

3. **第三方平台**:
   - 酷安
   - APKPure
   - 直接分发 APK 文件

### iOS

1. **App Store**: 唯一官方渠道
   - 需要开发者账号（$99/年）
   - 通过 App Store Connect 提交
   - 审核较严格（通常 1-7 天）

2. **TestFlight**: 内部测试
   - 通过 App Store Connect 邀请测试用户
   - 最多 10,000 个外部测试用户

3. **企业分发**: 需要企业账号（$299/年）

---

## 🔧 优化建议

### 减小应用体积

1. **使用 split-per-abi** (Android):
   ```bash
   flutter build apk --split-per-abi --release
   ```

2. **移除未使用的资源**:
   - 删除 `assets` 中未使用的图片
   - 压缩图片资源

3. **开启混淆和压缩**:
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
       }
   }
   ```

### 性能优化

1. **使用 --release 模式**: 生产环境必须用 release 模式
2. **图片优化**: 使用 WebP 格式
3. **懒加载**: 按需加载页面和资源
4. **Tree shaking**: Flutter 会自动移除未使用的代码

---

## 📝 打包清单

### 打包前检查

- [ ] 更新版本号（`pubspec.yaml`）
- [ ] 测试所有功能
- [ ] 检查网络请求地址（生产环境）
- [ ] 替换应用图标
- [ ] 配置应用名称
- [ ] 生成签名密钥（Android）
- [ ] 配置签名（Android）
- [ ] 配置证书（iOS）
- [ ] 检查权限配置（相机、位置等）
- [ ] 准备应用商店素材（截图、描述）

### 打包后测试

- [ ] 安装到真机测试
- [ ] 测试首次启动
- [ ] 测试网络功能
- [ ] 测试支付功能（如有）
- [ ] 测试分享功能（如有）
- [ ] 测试性能和卡顿
- [ ] 检查崩溃和异常

---

## 📚 参考资料

- [Flutter 官方文档 - Android 部署](https://docs.flutter.dev/deployment/android)
- [Flutter 官方文档 - iOS 部署](https://docs.flutter.dev/deployment/ios)
- [Google Play 开发者中心](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Android 应用签名](https://developer.android.com/studio/publish/app-signing)
- [iOS 证书管理](https://developer.apple.com/support/certificates/)

---

## 🎉 完成

按照本指南操作，你应该能成功打包出 Android 和 iOS 应用！

如有问题，请参考 [常见问题](#常见问题) 章节或查阅官方文档。

**祝打包顺利！** 🚀
