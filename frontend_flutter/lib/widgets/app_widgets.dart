import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// 自定义标签组件
/// 用于展示选中/未选中状态的标签
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final TextStyle? labelStyle;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leading,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.labelStyle,
    this.borderRadius = AppTheme.radiusMedium,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedBackgroundColor ?? AppTheme.primary)
        : (backgroundColor ?? AppTheme.bgSecondary);

    final textColor = isSelected ? Colors.white : AppTheme.textPrimary;

    final style = labelStyle ??
        TextStyle(
          fontSize: AppTheme.fontSizeBase,
          color: textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM,
            ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppTheme.spacingXS),
            ],
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}

/// 时间段选择卡片组件
/// 用于选择预约时间
class TimeSlotCard extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const TimeSlotCard({
    super.key,
    required this.time,
    this.isSelected = false,
    this.isAvailable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppTheme.primary
        : (isAvailable ? Colors.white : AppTheme.bgSecondary);

    final textColor = isSelected
        ? Colors.white
        : (isAvailable ? AppTheme.textPrimary : AppTheme.textTertiary);

    final borderColor = isSelected
        ? AppTheme.primary
        : (isAvailable ? AppTheme.border : AppTheme.textTertiary);

    return GestureDetector(
      onTap: isAvailable && !isSelected ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.shadowSmall : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLG,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (!isAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spacingXS),
                  child: Text(
                    '已预约',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeXS,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 理发师卡片组件
/// 用于展示和选择理发师
class StylistCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? specialty;
  final bool isSelected;
  final VoidCallback? onTap;

  const StylistCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.specialty,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.shadowSmall : AppTheme.shadowSmall,
        ),
        child: Column(
          children: [
            // 头像
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.bgSecondary,
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppTheme.bgSecondary,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                      ),
              ),
            ),
            // 信息部分
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeLG,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (specialty != null) ...[
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      specialty!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSM,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // 选中指示器
            if (isSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.radiusMedium),
                    bottomRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 预约确认卡片组件
/// 展示选中的服务、理发师、时间等信息
class BookingSummaryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onEdit;
  final EdgeInsetsGeometry? padding;

  const BookingSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onEdit,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: padding ??
          const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppTheme.spacingMD),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeLG,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: AppTheme.spacingMD),
            GestureDetector(
              onTap: onEdit,
              child: const Icon(
                Icons.edit,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}