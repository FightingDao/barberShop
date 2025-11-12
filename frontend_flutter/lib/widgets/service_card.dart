import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/models.dart';

/// 服务卡片组件
/// 展示服务选择页面中的服务信息，匹配frontend_old设计
class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppTheme.shadowPrimary : AppTheme.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Row(
              children: [
                // 服务图标
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: service.iconUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Image.network(
                            service.iconUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultIcon();
                            },
                          ),
                        )
                      : _buildDefaultIcon(),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                // 服务信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 服务名称
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLG,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (service.description != null) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          service.description!,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSM,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingSM),
                      // 价格和时长
                      Row(
                        children: [
                          // 价格
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSM,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              '¥${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSM,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSM),
                          // 时长
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSM,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppTheme.info,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${service.durationMinutes}分钟',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSizeXS,
                                    color: AppTheme.info,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 选中标记
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primary,
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: AppTheme.border,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(
      Icons.content_cut,
      size: 28,
      color: isSelected ? AppTheme.primary : AppTheme.textTertiary,
    );
  }
}
