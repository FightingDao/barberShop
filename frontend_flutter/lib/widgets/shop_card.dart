import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/models.dart';

/// 店铺卡片组件
/// 展示店铺列表中的店铺信息，匹配frontend_old设计
class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.shop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店铺图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: shop.avatarUrl != null
                      ? Image.network(
                          shop.avatarUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                // 店铺信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 店铺名称
                      Text(
                        shop.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLG,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      // 地址
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shop.address,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSM,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (shop.phone != null) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shop.phone!,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSM,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (shop.openingTime != null && shop.closingTime != null) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '营业时间: ${shop.openingTime} - ${shop.closingTime}',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSM,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingSM),
                      // 状态标签
                      _buildStatusChip(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: const Icon(
        Icons.store,
        size: 40,
        color: AppTheme.textTertiary,
      ),
    );
  }

  Widget _buildStatusChip() {
    final isOpen = shop.status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isOpen ? AppTheme.success.withOpacity(0.1) : AppTheme.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        isOpen ? '营业中' : '休息中',
        style: TextStyle(
          fontSize: AppTheme.fontSizeXS,
          color: isOpen ? AppTheme.success : AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
