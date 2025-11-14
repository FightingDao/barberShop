# Android 打包快速开始指南

## 当前状态

❌ Android SDK 未配置
✅ Android Studio 已安装
✅ Flutter 已安装

## 配置步骤（5分钟完成）

### 第1步：在 Android Studio 中安装 SDK

1. **打开 Android Studio**
   ```bash
   open -a "Android Studio"
   ```

2. **进入 SDK Manager**
   - 点击顶部菜单 `Android Studio` > `Settings`（或 `Preferences`）
   - 左侧导航选择 `Languages & Frameworks` > `Android SDK`

3. **安装必要组件**

   在 **SDK Platforms** 标签页：
   - ☑️ Android 14.0 ("UpsideDownCake") API 34
   - ☑️ Android 13.0 ("Tiramisu") API 33
   - ☑️ Android 5.0 (Lollipop) API 21

   在 **SDK Tools** 标签页：
   - ☑️ Android SDK Build-Tools
   - ☑️ Android SDK Command-line Tools
   - ☑️ Android SDK Platform-Tools
   - ☑️ Android Emulator（可选，用于测试）

4. **点击 "Apply" 开始安装**（需要等待 5-10 分钟）

5. **记下 SDK 路径**
   - 在 SDK Manager 窗口顶部显示，通常是：
   - macOS: `/Users/你的用户名/Library/Android/sdk`
   - 复制这个路径！

### 第2步：配置 Flutter 环境

打开终端，执行以下命令：

```bash
# 配置 ANDROID_HOME 环境变量
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.zshrc

# 重新加载配置
source ~/.zshrc

# 配置 Flutter
flutter config --android-sdk $ANDROID_HOME

# 接受许可
flutter doctor --android-licenses
```

输入 `y` 接受所有许可。

### 第3步：验证配置

```bash
flutter doctor
```

应该看到：
```
[✓] Android toolchain - develop for Android devices
```

### 第4步：构建 APK

#### 构建 Debug 版本（用于测试）

```bash
cd /Users/zhangdi/work/barberShop/frontend_flutter
flutter build apk --debug
```

输出位置: `build/app/outputs/flutter-apk/app-debug.apk`

#### 构建 Release 版本（需要先配置签名）

暂时跳过，等 Debug 版本成功后再配置。

---

## 手动配置（如果上面的步骤不work）

如果 SDK 路径不是默认位置，手动查找：

```bash
# 方法1：通过 Android Studio 查找
# 打开 Settings > Android SDK，顶部显示的就是路径

# 方法2：搜索
find ~ -name "platform-tools" -type d 2>/dev/null | grep Android
```

找到后，手动设置：

```bash
# 替换成你的实际路径
export ANDROID_HOME=/path/to/your/android/sdk
flutter config --android-sdk $ANDROID_HOME
```

---

## 常见问题

### Q1: SDK Manager 找不到？

**A**: 在 Android Studio 欢迎页面，点击右下角 `More Actions` > `SDK Manager`

### Q2: 许可接受失败？

**A**: 尝试手动接受：
```bash
yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
```

### Q3: 构建失败 - "Gradle build failed"

**A**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

### Q4: 网络太慢（国内）

**A**: 配置镜像，编辑 `android/build.gradle`：
```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'https://maven.aliyun.com/repository/public' }
    }
}
```

---

## 下一步

当你看到 `[✓] Android toolchain` 后，就可以：

1. ✅ 构建 Debug APK（测试）
2. ⏭️ 配置签名（Release APK）
3. ⏭️ 发布到应用市场

详细步骤请参考：`docs/APP_BUILD_GUIDE.md`

---

## 快速命令参考

```bash
# 检查环境
flutter doctor

# 构建 Debug APK
flutter build apk --debug

# 构建 Release APK（需要签名）
flutter build apk --release

# 构建并分离不同架构（减小体积）
flutter build apk --split-per-abi --release

# 安装到设备
adb install build/app/outputs/flutter-apk/app-debug.apk

# 运行到设备
flutter run --release
```

---

需要帮助？查看完整文档：`docs/APP_BUILD_GUIDE.md`
