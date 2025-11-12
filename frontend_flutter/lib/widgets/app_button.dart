import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 自定义按钮组件
/// 带有渐变色背景和阴影效果，匹配frontend_old设计
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusMedium,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    if (isOutlined) {
      return _buildOutlinedButton(isDisabled);
    }

    return _buildFilledButton(isDisabled);
  }

  Widget _buildFilledButton(bool isDisabled) {
    return Container(
      width: width,
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? AppTheme.textDisabled : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDisabled ? null : AppTheme.shadowPrimary,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingMD,
                ),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(bool isDisabled) {
    return Container(
      width: width,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isDisabled ? AppTheme.textDisabled : AppTheme.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingMD,
                ),
            child: _buildButtonContent(textColor: AppTheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent({Color textColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppTheme.primary : Colors.white,
              ),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: AppTheme.spacingSM),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: AppTheme.fontSizeLG,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
