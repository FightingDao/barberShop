import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/shop_provider.dart';
import '../widgets/widgets.dart';

/// 店铺详情页 - 严格按照设计稿还原
class ShopDetailPage extends StatefulWidget {
  final int shopId;

  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  late ShopProvider _shopProvider;
  bool _isInitialized = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    _shopProvider = context.read<ShopProvider>();
    if (!_isInitialized) {
      _shopProvider.fetchShopDetail(widget.shopId);
      _shopProvider.fetchServices(widget.shopId);
      _shopProvider.fetchStylists(widget.shopId);
      _isInitialized = true;
    }
  }

  void _startBooking() {
    final shop = _shopProvider.selectedShop;
    if (shop != null) {
      context.push('/booking/select-service/${shop.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, _) {
          // 加载中状态
          if (shopProvider.isLoading && shopProvider.selectedShop == null) {
            return const LoadingWidget(message: '加载中...');
          }

          // 错误状态
          if (shopProvider.errorMessage != null && shopProvider.selectedShop == null) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: AppErrorWidget(
                    message: shopProvider.errorMessage ?? '加载失败',
                    onRetry: () => _shopProvider.fetchShopDetail(widget.shopId),
                  ),
                ),
              ],
            );
          }

          final shop = shopProvider.selectedShop;
          if (shop == null) {
            return Column(
              children: [
                _buildHeader(context),
                const Expanded(
                  child: EmptyWidget(
                    message: '店铺信息加载失败',
                    icon: Icons.store_outlined,
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              // 主内容区域
              CustomScrollView(
                slivers: [
                  // 顶部间距（为固定header留空间）
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 56),
                  ),
                  // 店铺大图
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 256,
                      width: double.infinity,
                      child: shop.image != null && shop.image!.isNotEmpty
                          ? Image.network(
                              shop.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage(shop.name);
                              },
                            )
                          : _buildPlaceholderImage(shop.name),
                    ),
                  ),
                  // 店铺信息卡片 - 常规布局
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _buildShopInfoCard(shop),
                    ),
                  ),
                  // 内容区域
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 服务项目
                          _buildServicesSection(shopProvider),
                          const SizedBox(height: 16),
                          // 理发师团队
                          _buildStylistsSection(shopProvider),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 固定顶部导航栏
              _buildHeader(context),
              // 固定底部预约按钮
              _buildBottomButton(),
            ],
          );
        },
      ),
    );
  }

  // 构建固定顶部导航栏
  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              children: [
                // 返回按钮
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ),
                // 标题
                const Center(
                  child: Text(
                    '店铺详情',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 收藏按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Icon(
                          _isFavorite ? LucideIcons.heart : LucideIcons.heart,
                          size: 20,
                          color: _isFavorite ? const Color(0xFFFF385C) : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 格式化时间字符串
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    try {
      // 尝试解析 ISO 8601 格式 (如 "1970-01-01T01:00:00.000Z")
      final dateTime = DateTime.parse(time);
      // 转换为本地时间
      final localTime = dateTime.toLocal();
      final hour = localTime.hour;
      final minute = localTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      // 如果解析失败，尝试处理简单的 "HH:MM:SS" 格式
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.isNotEmpty) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = parts.length > 1 ? parts[1] : '00';
          return '$hour:$minute';
        }
      }
      return time;
    }
  }

  // 构建店铺基本信息卡片
  Widget _buildShopInfoCard(dynamic shop) {
    final isOpen = shop.status == 'active' || shop.status == 'open';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 店铺名称和营业状态
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF385C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOpen ? '营业中' : '休息中',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 评分、人均、已售
            Row(
              children: [
                const Icon(LucideIcons.star, size: 16, color: Color(0xFFFBBF24)),
                const SizedBox(width: 4),
                Text(
                  '${shop.rating ?? 4.8}分',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  '|',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 16),
                Text(
                  '人均 ¥${shop.avgPrice ?? 88}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  '|',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 16),
                const Text(
                  '已售902',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 地址
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 20,
                    color: Color(0xFFFF385C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '距离您 ${shop.distance ?? '2.1km'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 营业时间
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '营业时间',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        Text(
                          shop.openingTime != null && shop.closingTime != null
                              ? '${_formatTime(shop.openingTime)} - ${_formatTime(shop.closingTime)}'
                              : '9:00 - 21:00',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建服务项目区域
  Widget _buildServicesSection(ShopProvider shopProvider) {
    // 使用实际的服务数据
    final services = shopProvider.services;

    // 如果没有服务数据，显示空状态
    if (services.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '服务项目',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '暂无服务项目',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '服务项目',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDF2F8), Colors.white],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      LucideIcons.scissors,
                      size: 20,
                      color: Color(0xFFFF385C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${service.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFFF385C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 构建理发师团队区域
  Widget _buildStylistsSection(ShopProvider shopProvider) {
    // 使用实际的理发师数据
    final stylists = shopProvider.stylists;

    // 如果没有理发师数据，显示空状态
    if (stylists.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '理发师团队',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '暂无理发师信息',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '理发师团队',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceAround,
            children: stylists.map((stylist) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 32 - 40 - 32) / 3, // 考虑padding和spacing
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFCE7F3), Color(0xFFE9D5FF)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: stylist.avatarUrl != null && stylist.avatarUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.network(
                                  stylist.avatarUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFFFF385C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFFFF385C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stylist.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stylist.title ?? '理发师',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 构建固定底部预约按钮
  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: _startBooking,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF385C),
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '立即预约',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建占位图片
  Widget _buildPlaceholderImage(String shopName) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF472B6), Color(0xFFFB7185)],
        ),
      ),
      child: Center(
        child: Text(
          shopName.isNotEmpty ? shopName.substring(0, 1) : '店',
          style: const TextStyle(
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
