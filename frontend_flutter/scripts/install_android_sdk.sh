#!/bin/bash

# Android SDK 命令行安装脚本
# 这个脚本会自动下载和安装 Android SDK

set -e

echo "=== Android SDK 自动安装脚本 ==="
echo ""

# 定义变量
SDK_DIR="$HOME/Library/Android/sdk"
CMDLINE_TOOLS_VERSION="11076708"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-${CMDLINE_TOOLS_VERSION}_latest.zip"
TEMP_DIR="/tmp/android-sdk-setup"

# 创建临时目录
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "1. 下载 Android SDK Command Line Tools..."
curl -o commandlinetools.zip "$CMDLINE_TOOLS_URL"

echo ""
echo "2. 解压 Command Line Tools..."
unzip -q commandlinetools.zip

echo ""
echo "3. 移动到 SDK 目录..."
mkdir -p "$SDK_DIR/cmdline-tools/latest"
mv cmdline-tools/* "$SDK_DIR/cmdline-tools/latest/"

echo ""
echo "4. 设置环境变量..."
export ANDROID_HOME="$SDK_DIR"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

echo ""
echo "5. 接受许可..."
yes | "$SDK_DIR/cmdline-tools/latest/bin/sdkmanager" --licenses

echo ""
echo "6. 安装必要的 SDK 组件..."
"$SDK_DIR/cmdline-tools/latest/bin/sdkmanager" \
  "platform-tools" \
  "platforms;android-34" \
  "platforms;android-33" \
  "platforms;android-21" \
  "build-tools;34.0.0" \
  "build-tools;33.0.0"

echo ""
echo "7. 清理临时文件..."
rm -rf "$TEMP_DIR"

echo ""
echo "=== 安装完成！ ==="
echo ""
echo "SDK 位置: $SDK_DIR"
echo ""
echo "下一步: 运行以下命令配置 Flutter"
echo "  export ANDROID_HOME=$SDK_DIR"
echo "  export PATH=\$PATH:\$ANDROID_HOME/platform-tools"
echo "  flutter config --android-sdk \$ANDROID_HOME"
echo "  flutter doctor"
echo ""
