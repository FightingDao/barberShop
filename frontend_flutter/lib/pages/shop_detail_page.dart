import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../providers/shop_provider.dart';
import '../widgets/widgets.dart';

/// 店铺详情页
/// 显示店铺的详细信息和预约入口
class ShopDetailPage extends StatefulWidget {
  final int shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  late ShopProvider _shopProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化数据
  void _initializeData() {
    _shopProvider = context.read<ShopProvider>();
    if (!_isInitialized) {
      _shopProvider.fetchShopDetail(widget.shopId);
      _isInitialized = true;
    }
  }

  /// 开始预约
  void _startBooking() {
    final shop = _shopProvider.selectedShop;
    if (shop != null) {
      context.push('/booking/select-service/${shop.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, _) {
          // 加载中状态
          if (shopProvider.isLoading && shopProvider.selectedShop == null) {
            return const Scaffold(
              body: LoadingWidget(message: '加载中...'),
            );
          }

          // 错误状态
          if (shopProvider.errorMessage != null &&
              shopProvider.selectedShop == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppErrorWidget(
                message: shopProvider.errorMessage ?? '加载失败',
                onRetry: () => _shopProvider.fetchShopDetail(widget.shopId),
              ),
            );
          }

          final shop = shopProvider.selectedShop;
          if (shop == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyWidget(
                message: '店铺信息加载失败',
                icon: Icons.store_outlined,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: shop.avatarUrl != null
                      ? Image.network(
                          shop.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.bgSecondary,
                              child: const Icon(
                                Icons.store,
                                size: 64,
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.bgSecondary,
                          child: const Icon(
                            Icons.store,
                            size: 64,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                ),
              ),
              // 内容
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 店铺基本信息
                      _buildShopInfo(shop),
                      const SizedBox(height: AppTheme.spacingXXL),
                      // 营业时间
                      _buildOperatingHours(shop),
                      const SizedBox(height: AppTheme.spacingLG),
                      // 联系方式
                      _buildContactInfo(shop),
                      const SizedBox(height: AppTheme.spacingLG),
                      // 店铺描述
                      if (shop.description != null)
                        _buildDescription(shop.description!),
                      const SizedBox(height: AppTheme.spacingXXL),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ShopProvider>(
        builder: (context, shopProvider, _) {
          return BottomActionBar(
            primaryButtonText: '立即预约',
            onPrimaryPressed: _startBooking,
            isLoading: shopProvider.isLoading,
          );
        },
      ),
    );
  }

  /// 构建店铺基本信息
  Widget _buildShopInfo(dynamic shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        // 状态标签
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: shop.status == 'active'
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.textTertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Text(
            shop.status == 'active' ? '营业中' : '休息中',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color:
                  shop.status == 'active' ? AppTheme.success : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建营业时间
  Widget _buildOperatingHours(dynamic shop) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: AppTheme.spacingMD),
              const Text(
                '营业时间',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLG,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          if (shop.openingTime != null && shop.closingTime != null)
            Text(
              '${shop.openingTime} - ${shop.closingTime}',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: AppTheme.textSecondary,
              ),
            )
          else
            const Text(
              '信息暂未提供',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: AppTheme.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建联系方式
  Widget _buildContactInfo(dynamic shop) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: AppTheme.spacingMD),
              const Text(
                '联系电话',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLG,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          if (shop.phone != null)
            GestureDetector(
              onTap: () {
                // TODO: 拨打电话
              },
              child: Text(
                shop.phone!,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeBase,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            const Text(
              '信息暂未提供',
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: AppTheme.textTertiary,
              ),
            ),
          const SizedBox(height: AppTheme.spacingLG),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: AppTheme.spacingMD),
              const Text(
                '地址',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLG,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            shop.address,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建店铺描述
  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '店铺介绍',
          style: TextStyle(
            fontSize: AppTheme.fontSizeLG,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        Text(
          description,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeBase,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
