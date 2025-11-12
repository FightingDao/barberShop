import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgPrimary,
            borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
            boxShadow: AppTheme.shadowLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShopImageSection(shop: shop),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shop.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (shop.description != null &&
                        shop.description!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          shop.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _buildPrimaryInfo(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        _StatusBadge(status: shop.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildPrimaryInfo() {
    if (shop.phone != null && shop.phone!.isNotEmpty) {
      return '电话：${shop.phone}';
    }
    if (shop.openingTime != null && shop.closingTime != null) {
      return '营业时间 ${shop.openingTime}-${shop.closingTime}';
    }
    return '欢迎预约体验';
  }

  bool get _isOpen => shop.status == 'active' || shop.status == 'open';
}

class _ShopImageSection extends StatelessWidget {
  final Shop shop;

  const _ShopImageSection({required this.shop});

  @override
  Widget build(BuildContext context) {
    final image = shop.avatarUrl;

    return ClipRRect
(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppTheme.radiusXXL),
        topRight: Radius.circular(AppTheme.radiusXXL),
      ),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null && image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _PlaceholderImage(name: shop.name);
                },
              )
            else
              _PlaceholderImage(name: shop.name),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                constraints: const BoxConstraints(maxWidth: 180),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        shop.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (shop.status != 'active' && shop.status != 'open')
              Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: _ClosedLabel(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String name;

  const _PlaceholderImage({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9EC1), Color(0xFFFF4D6A)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.characters.first : '店',
          style: const TextStyle(
            fontSize: 42,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ClosedLabel extends StatelessWidget {
  const _ClosedLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '已打烊',
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  bool get _isOpen => status == 'active' || status == 'open';

  @override
  Widget build(BuildContext context) {
    final color = _isOpen ? const Color(0xFF22C55E) : AppTheme.textSecondary;
    final background = _isOpen
        ? const Color(0x1A22C55E)
        : AppTheme.textSecondary.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOpen ? LucideIcons.clock : LucideIcons.moon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _isOpen ? '营业中' : '休息中',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
