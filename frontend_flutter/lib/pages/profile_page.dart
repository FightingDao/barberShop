import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../providers/providers.dart';

/// 个人中心页
/// 显示用户信息和应用设置
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// 退出登录
  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部导航
            _buildAppBar(context),

            // 内容区域
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ListView(
                    padding: const EdgeInsets.all(AppTheme.paddingLg),
                    children: [
                      // 用户信息卡片
                      _buildUserInfoCard(authProvider),
                      const SizedBox(height: AppTheme.paddingLg),

                      // 功能列表
                      _buildFunctionCard(context),
                      const SizedBox(height: AppTheme.paddingLg),

                      // 关于应用
                      _buildAboutCard(),
                      const SizedBox(height: AppTheme.paddingLg),

                      // 退出登录按钮
                      _buildLogoutButton(context),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMd),

          // 标题
          const Text(
            '个人中心',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(AuthProvider authProvider) {
    final user = authProvider.user;

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingXxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLg),

          // 用户名
          Text(
            user?.nickname ?? '用户',
            style: const TextStyle(
              fontSize: AppTheme.fontSizeXl,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSm),

          // 手机号
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMd,
              vertical: AppTheme.paddingSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: AppTheme.paddingSm),
                Text(
                  user?.phone ?? '-',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能卡片
  Widget _buildFunctionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.event_note,
            title: '我的预约',
            subtitle: '查看预约记录',
            onTap: () => context.go('/appointments'),
          ),
          _buildDivider(),
          _buildFunctionItem(
            icon: Icons.store,
            title: '店铺列表',
            subtitle: '浏览所有店铺',
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  /// 构建功能项
  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        child: Row(
          children: [
            // 图标
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMd),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.paddingLg),

            // 文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSm,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 箭头
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建关于应用卡片
  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppTheme.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '关于应用',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),

          _buildInfoRow('应用名称', '理发店预约系统'),
          _buildInfoRow('版本号', 'v1.0.0'),
          _buildInfoRow('开发团队', 'Flutter Team'),

          const SizedBox(height: AppTheme.paddingMd),
          const Text(
            '感谢您使用我们的应用！如有任何问题或建议，欢迎联系我们。',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.textTertiary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建退出登录按钮
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppTheme.error),
            SizedBox(width: AppTheme.paddingSm),
            Text(
              '退出登录',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLg,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
      child: Divider(height: 1),
    );
  }
}
