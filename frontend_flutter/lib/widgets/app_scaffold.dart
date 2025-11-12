import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'app_button.dart';

/// 应用页面布局组件
/// 提供统一的页面结构：顶部导航栏 + 内容区域 + 底部操作栏
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final double elevation;
  final bool safeArea;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.onBack,
    this.showBackButton = true,
    this.bottom,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.centerTitle = true,
    this.titleStyle,
    this.elevation = 0,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: title != null
          ? Text(
              title!,
              style: titleStyle ??
                  const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.fontSizeLG,
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      backgroundColor: AppTheme.bgPrimary,
      foregroundColor: AppTheme.textPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
    );

    final scaffold = Scaffold(
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor ?? AppTheme.bgSecondary,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );

    return safeArea ? SafeArea(child: scaffold) : scaffold;
  }
}

/// 应用卡片布局组件
/// 用于展示内容的卡片容器
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius = AppTheme.radiusMedium,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLG),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ?? AppTheme.shadowSmall,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// 分割线组件
/// 用于在页面中创建视觉分割
class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const AppDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
      height: height,
      color: color ?? AppTheme.border,
    );
  }
}

/// 底部操作按钮栏组件
/// 用于放置底部确认按钮
class BottomActionBar extends StatelessWidget {
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const BottomActionBar({
    super.key,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.isLoading = false,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingLG,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.bgPrimary,
        boxShadow: AppTheme.shadowLarge,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (secondaryButtonText != null) ...[
              Expanded(
                child: AppButton(
                  text: secondaryButtonText!,
                  onPressed: isLoading ? null : onSecondaryPressed,
                  isOutlined: true,
                  isLoading: false,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
            ],
            Expanded(
              child: AppButton(
                text: primaryButtonText ?? '确定',
                onPressed: isLoading ? null : onPrimaryPressed,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 导入 AppButton
