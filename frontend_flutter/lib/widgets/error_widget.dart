import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 错误展示组件
/// 显示错误信息和重试按钮
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.fontSizeBase,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
