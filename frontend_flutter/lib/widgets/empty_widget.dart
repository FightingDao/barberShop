import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 空状态展示组件
/// 显示空状态信息和图标
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
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
              size: 80,
              color: AppTheme.textTertiary,
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
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
