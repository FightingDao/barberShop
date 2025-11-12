import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../providers/providers.dart';

/// 确认预约页
/// 显示所有预约信息供用户确认并提交
class ConfirmBookingPage extends StatefulWidget {
  final int shopId;

  const ConfirmBookingPage({super.key, required this.shopId});

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
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

  /// 返回修改
  void _handleGoBack() {
    context.pop();
  }

  /// 确认预约
  Future<void> _handleConfirmBooking() async {
    final bookingProvider = context.read<BookingProvider>();

    // 检查预约信息是否完整
    if (!bookingProvider.canCreateAppointment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预约信息不完整')),
      );
      return;
    }

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认预约'),
        content: const Text('请确认预约信息无误后提交'),
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
            child: const Text('确认', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final appointment = await bookingProvider.createAppointment(
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (!mounted) return;

      if (appointment != null) {
        // 预约成功，导航到成功页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('预约成功！')),
        );
        context.go('/booking/success');
      } else {
        // 预约失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.errorMessage ?? '预约失败，请重试'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('预约失败：$e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部导航
            _buildAppBar(),

            // 内容区域
            Expanded(
              child: Consumer2<BookingProvider, AuthProvider>(
                builder: (context, bookingProvider, authProvider, _) {
                  return _buildContent(bookingProvider, authProvider);
                },
              ),
            ),

            // 底部操作栏
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar() {
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
            onTap: _handleGoBack,
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
            '确认预约',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(BookingProvider bookingProvider, AuthProvider authProvider) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      children: [
        // 预约信息确认
        _buildBookingInfo(bookingProvider),
        const SizedBox(height: AppTheme.paddingLg),

        // 联系信息
        _buildContactInfo(authProvider),
        const SizedBox(height: AppTheme.paddingLg),

        // 备注
        _buildNotes(),
        const SizedBox(height: AppTheme.paddingLg),

        // 温馨提示
        _buildTips(),
      ],
    );
  }

  /// 构建预约信息
  Widget _buildBookingInfo(BookingProvider bookingProvider) {
    final shop = bookingProvider.selectedShop;
    final service = bookingProvider.selectedService;
    final stylist = bookingProvider.selectedStylist;
    final date = bookingProvider.selectedDate;
    final time = bookingProvider.selectedTime;

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
          // 标题
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '预约信息',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.1)],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLg),

          // 店铺名称
          _buildInfoRow(
            '店铺名称',
            shop?.name ?? '',
            isHighlight: true,
          ),

          // 店铺地址
          _buildInfoRow(
            '店铺地址',
            shop?.address ?? '',
          ),

          // 服务项目
          _buildInfoRow(
            '服务项目',
            service?.name ?? '',
            isHighlight: true,
          ),

          // 理发师
          _buildInfoRow(
            '理发师',
            stylist?.name ?? '不指定',
          ),

          // 预约时间
          _buildInfoRow(
            '预约时间',
            '${_formatDate(date)}\n${time?.substring(0, 5) ?? ''}',
            isHighlight: true,
            valueColor: AppTheme.primary,
          ),

          // 服务时长
          _buildInfoRow(
            '服务时长',
            '${service?.durationMinutes ?? 0}分钟',
          ),

          // 服务价格
          Container(
            margin: const EdgeInsets.only(top: AppTheme.paddingMd),
            padding: const EdgeInsets.all(AppTheme.paddingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.primary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '服务价格',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  '¥${service?.price.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeHuge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建联系信息
  Widget _buildContactInfo(AuthProvider authProvider) {
    final user = authProvider.user;

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
          // 标题
          Row(
            children: [
              const Text('👤', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '联系信息',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.1)],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLg),

          // 姓名
          _buildInfoRow(
            '姓名',
            user?.nickname ?? '用户',
            isHighlight: true,
          ),

          // 手机号
          _buildInfoRow(
            '手机号',
            user?.phone ?? '',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  /// 构建备注输入
  Widget _buildNotes() {
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
          // 标题
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '备注信息',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '(可选)',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSm,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // 输入框
          TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '请输入备注信息，如特殊需求、发型要求等',
              hintStyle: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.textTertiary,
              ),
              filled: true,
              fillColor: AppTheme.bgTertiary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppTheme.paddingMd),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建温馨提示
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.warning),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppTheme.paddingSm),
              const Text(
                '温馨提示',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMd,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TipItem(text: '请提前10分钟到店避免迟到影响服务'),
              _TipItem(text: '如需取消预约，请提前2小时操作'),
              _TipItem(text: '请保持手机畅通，方便店铺联系'),
              _TipItem(text: '到店时请向工作人员出示预约码'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMd),
      padding: EdgeInsets.all(isHighlight ? AppTheme.paddingSm : 0),
      decoration: isHighlight
          ? BoxDecoration(
              color: AppTheme.bgTertiary,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTheme.fontSizeBase,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: const Border(top: BorderSide(color: AppTheme.borderLight)),
        boxShadow: AppTheme.shadowLarge,
      ),
      child: Row(
        children: [
          // 返回修改按钮
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _handleGoBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                ),
                child: const Text(
                  '返回修改',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMd),

          // 确认预约按钮
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleConfirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '确认预约',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              color: AppTheme.warning,
              height: 1.8,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.warning,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
