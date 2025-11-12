import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../providers/providers.dart';

/// 预约成功页
/// 显示预约成功信息和后续操作
class BookingSuccessPage extends StatefulWidget {
  const BookingSuccessPage({super.key});

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 格式化日期显示
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

      String prefix = '';
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        prefix = '今天 ';
      } else if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day + 1) {
        prefix = '明天 ';
      }

      return '$prefix${date.year}年${date.month}月${date.day}日 ${weekdays[date.weekday % 7]}';
    } catch (e) {
      return dateStr;
    }
  }

  /// 返回首页
  void _handleGoHome() {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.clear(); // 清空预约状态
    context.go('/');
  }

  /// 查看我的预约
  void _handleViewAppointments() {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.clear(); // 清空预约状态
    context.go('/appointments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            return Column(
              children: [
                // 内容区域
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.paddingXxl),
                    children: [
                      const SizedBox(height: AppTheme.paddingXxl),

                      // 成功图标动画
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.success.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingXxl),

                      // 成功标题
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          '预约成功！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingMd),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          '我们已收到您的预约请求',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingXxl),

                      // 预约信息卡片
                      _buildBookingInfoCard(bookingProvider),
                      const SizedBox(height: AppTheme.paddingLg),

                      // 温馨提示
                      _buildTipsCard(),
                    ],
                  ),
                ),

                // 底部操作栏
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建预约信息卡片
  Widget _buildBookingInfoCard(BookingProvider bookingProvider) {
    final shop = bookingProvider.selectedShop;
    final service = bookingProvider.selectedService;
    final stylist = bookingProvider.selectedStylist;
    final date = bookingProvider.selectedDate;
    final time = bookingProvider.selectedTime;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingXxl),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowMedium,
        ),
        child: Column(
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingSm),
                const Text(
                  '预约详情',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingXxl),

            // 店铺信息
            _buildInfoSection(
              icon: Icons.store,
              title: '店铺信息',
              children: [
                _buildInfoRow('店铺名称', shop?.name ?? '-'),
                _buildInfoRow('店铺地址', shop?.address ?? '-'),
                if (shop?.phone != null)
                  _buildInfoRow('联系电话', shop!.phone!),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLg),

            _buildDivider(),
            const SizedBox(height: AppTheme.paddingLg),

            // 服务信息
            _buildInfoSection(
              icon: Icons.content_cut,
              title: '服务信息',
              children: [
                _buildInfoRow('服务项目', service?.name ?? '-'),
                _buildInfoRow('理发师', stylist?.name ?? '不指定'),
                _buildInfoRow(
                  '服务时长',
                  '${service?.durationMinutes ?? 0}分钟',
                ),
                _buildInfoRow(
                  '服务价格',
                  '¥${service?.price.toStringAsFixed(0) ?? '0'}',
                  valueColor: AppTheme.primary,
                  valueBold: true,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLg),

            _buildDivider(),
            const SizedBox(height: AppTheme.paddingLg),

            // 预约时间
            _buildInfoSection(
              icon: Icons.access_time,
              title: '预约时间',
              children: [
                _buildInfoRow(
                  '预约日期',
                  _formatDate(date),
                  valueColor: AppTheme.primary,
                  valueBold: true,
                ),
                _buildInfoRow(
                  '预约时段',
                  time?.substring(0, 5) ?? '-',
                  valueColor: AppTheme.primary,
                  valueBold: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息段落
  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.paddingSm),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMd,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMd),
        ...children,
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.border.withOpacity(0.1),
            AppTheme.border,
            AppTheme.border.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  /// 构建温馨提示卡片
  Widget _buildTipsCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        decoration: BoxDecoration(
          color: AppTheme.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.info),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.info,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingSm),
                const Text(
                  '温馨提示',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMd,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMd),
            const _TipItem(
              icon: Icons.schedule,
              text: '请提前10分钟到店，避免迟到影响服务',
            ),
            const _TipItem(
              icon: Icons.phone,
              text: '请保持手机畅通，方便店铺联系您',
            ),
            const _TipItem(
              icon: Icons.qr_code,
              text: '到店时请向工作人员出示您的预约信息',
            ),
            const _TipItem(
              icon: Icons.cancel_outlined,
              text: '如需取消预约，请提前2小时操作',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        boxShadow: AppTheme.shadowLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 查看我的预约按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleViewAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, color: Colors.white),
                  SizedBox(width: AppTheme.paddingSm),
                  Text(
                    '查看我的预约',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLg,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // 返回首页按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _handleGoHome,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
              ),
              child: const Text(
                '返回首页',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 提示项组件
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.info,
          ),
          const SizedBox(width: AppTheme.paddingSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
