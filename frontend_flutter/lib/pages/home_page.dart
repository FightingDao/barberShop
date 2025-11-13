import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/shop.dart';
import '../providers/shop_provider.dart';
import '../widgets/widgets.dart';

/// 首页（店铺列表）- 严格按照设计稿还原
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  _HomeHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF472B6), Color(0xFFFB7185)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '发现美好',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '找到最适合你的理发店',
                style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  return Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 8),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: '搜索理发店...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            LucideIcons.search,
                            size: 20,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        suffixIcon: value.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                onPressed: onClearSearch,
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.searchController != searchController ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  late ShopProvider _shopProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _shopProvider = context.read<ShopProvider>();
    if (!_isInitialized) {
      _shopProvider.fetchShops();
      _isInitialized = true;
    }
  }

  Future<void> _searchShops(String keyword) async {
    if (keyword.isEmpty) {
      _shopProvider.fetchShops();
    } else {
      _shopProvider.searchShops(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, _) {
          return RefreshIndicator(
            onRefresh: () => _searchShops(_searchController.text),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeHeaderDelegate(
                    minExtent: 230,
                    maxExtent: 230,
                    searchController: _searchController,
                    onSearchChanged: _searchShops,
                    onClearSearch: () {
                      _searchController.clear();
                      _searchShops('');
                    },
                  ),
                ),
                // 店铺列表
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  sliver: shopProvider.isLoading && shopProvider.shops.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(
                            child: LoadingWidget(message: '加载中...'),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final shop = shopProvider.shops[index];
                            return _DesignShopCard(
                              shop: shop,
                              onTap: () => context.go('/shop/${shop.id}'),
                            );
                          }, childCount: shopProvider.shops.length),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 严格按照设计稿的店铺卡片
class _DesignShopCard extends StatefulWidget {
  final Shop shop;
  final VoidCallback onTap;

  const _DesignShopCard({required this.shop, required this.onTap});

  @override
  State<_DesignShopCard> createState() => _DesignShopCardState();
}

class _DesignShopCardState extends State<_DesignShopCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = widget.shop.status == 'active' || widget.shop.status == 'open';

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // rounded-2xl
                boxShadow: [
                  BoxShadow(
                    color: _isHovering ? const Color(0x26000000) : const Color(0x1A000000),
                    offset: const Offset(0, 4),
                    blurRadius: _isHovering ? 30 : 25,
                  ),
                ],
              ),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // 店铺图片
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: widget.shop.image != null && widget.shop.image!.isNotEmpty
                            ? Image.network(
                                widget.shop.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage();
                                },
                              )
                            : _buildPlaceholderImage(),
                      ),
                    ),
                    // 关闭状态遮罩
                    if (!isOpen)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Center(child: _ClosedBadge()),
                      ),
                    // 距离标签 - 右上角
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.shop.distance ?? '1.2km',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 信息区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 店铺名称
                    Text(
                      widget.shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF111827), // text-gray-900
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 地址
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: Color(0xFF4B5563),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.shop.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563), // text-gray-600
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 底部信息
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 价格
                        Text(
                          '¥${widget.shop.avgPrice ?? 88}起',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFF385C), // 设计稿中的红色
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // 营业状态
                        if (isOpen)
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.clock,
                                size: 16,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '营业中',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF059669), // text-green-600
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
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
          widget.shop.name.isNotEmpty ? widget.shop.name.substring(0, 1) : '店',
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ClosedBadge extends StatelessWidget {
  const _ClosedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '已打烊',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF111827),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
