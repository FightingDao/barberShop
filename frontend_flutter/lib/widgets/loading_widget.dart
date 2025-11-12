import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 加载指示器组件
/// 显示一个居中的加载动画
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              message!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.fontSizeBase,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型加载指示器
/// 用于按钮或其他小型组件中
class SmallLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const SmallLoadingWidget({
    super.key,
    this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
        strokeWidth: 2.0,
      ),
    );
  }
}
