import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Toast通知工具类
/// 用于显示各种类型的提示信息
class ToastUtils {
  /// 显示普通提示
  static void show(
    String message, {
    Toast? length,
    ToastGravity? gravity,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示成功提示
  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppTheme.success,
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示错误提示
  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppTheme.error,
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示警告提示
  static void warning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppTheme.warning,
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示信息提示
  static void info(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppTheme.info,
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示加载提示
  static void loading(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 取消所有Toast
  static void cancel() {
    Fluttertoast.cancel();
  }

  /// 显示顶部提示
  static void showTop(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示底部提示
  static void showBottom(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }

  /// 显示长时间提示
  static void showLong(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: AppTheme.fontSizeBase,
    );
  }
}
