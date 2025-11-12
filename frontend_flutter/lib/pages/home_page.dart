import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/widgets.dart';

/// 首页（店铺列表）
/// 显示所有可用的理发店列表，支持搜索功能
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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

  /// 初始化数据
  void _initializeData() {
    _shopProvider = context.read<ShopProvider>();
    if (!_isInitialized) {
      _shopProvider.fetchShops();
      _isInitialized = true;
    }
  }

  /// 搜索店铺
  Future<void> _searchShops(String keyword) async {
    if (keyword.isEmpty) {
      _shopProvider.fetchShops();
    } else {
      _shopProvider.searchShops(keyword);
    }
  }

  /// 退出登录
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('是否确认退出登录？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: const Text('确认', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      appBar: AppBar(
        title: const Text('理发店预约'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/appointments'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 店铺列表
          Expanded(
            child: Consumer<ShopProvider>(
              builder: (context, shopProvider, _) {
                // 加载中状态
                if (shopProvider.isLoading && shopProvider.shops.isEmpty) {
                  return const LoadingWidget(message: '加载中...');
                }

                // 错误状态
                if (shopProvider.errorMessage != null &&
                    shopProvider.shops.isEmpty) {
                  return AppErrorWidget(
                    message: shopProvider.errorMessage ?? '加载失败',
                    onRetry: () {
                      _searchController.clear();
                      _shopProvider.fetchShops();
                    },
                  );
                }

                // 空状态
                if (shopProvider.shops.isEmpty) {
                  return EmptyWidget(
                    message: '暂无店铺',
                    icon: Icons.store_outlined,
                  );
                }

                // 店铺列表
                return RefreshIndicator(
                  onRefresh: () => _searchShops(_searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingLG),
                    itemCount: shopProvider.shops.length,
                    itemBuilder: (context, index) {
                      final shop = shopProvider.shops[index];
                      return ShopCard(
                        shop: shop,
                        onTap: () => context.push('/shop/${shop.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.bgPrimary,
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchShops,
                decoration: InputDecoration(
                  hintText: '搜索店铺...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: AppTheme.fontSizeBase,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _searchShops('');
                          },
                          child: const Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMD,
                    vertical: AppTheme.spacingSM,
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.fontSizeBase,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
