import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';
import '../services/booking_service.dart';
import '../utils/toast_utils.dart';

/// 确认预约页面 - 严格按照设计风格还原
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

  /// 确认预约
  Future<void> _handleConfirmBooking() async {
    final bookingProvider = context.read<BookingProvider>();

    // 验证必要数据
    final shop = bookingProvider.selectedShop;
    final service = bookingProvider.selectedService;
    final date = bookingProvider.selectedDate;
    final time = bookingProvider.selectedTime;

    if (shop == null || service == null || date == null || time == null) {
      ToastUtils.show('预约信息不完整，请重新选择');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 调用真实API创建预约
      final appointment = await BookingService.instance.createAppointment(
        shopId: shop.id,
        serviceId: service.id,
        appointmentDate: date,
        appointmentTime: time,
        stylistId: bookingProvider.selectedStylist?.id,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;

      if (appointment != null) {
        // 预约成功，跳转到成功页面
        context.go('/booking/success');
      } else {
        ToastUtils.show('预约失败，请稍后重试');
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.show('预约失败：${e.toString()}');
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
      backgroundColor: const Color(0xFFF7F8FA),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          return Stack(
            children: [
              // 主内容区域
              CustomScrollView(
                slivers: [
                  // 顶部间距（为固定header留空间）
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 56),
                  ),
                  // 内容区域
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 预约信息卡片
                          _buildBookingInfoCard(bookingProvider),
                          const SizedBox(height: 16),
                          // 联系信息卡片
                          _buildContactInfoCard(context),
                          const SizedBox(height: 16),
                          // 备注输入
                          _buildNotesCard(),
                          const SizedBox(height: 16),
                          // 温馨提示
                          _buildTipsCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 固定顶部导航栏
              _buildHeader(),
              // 固定底部操作栏
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
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
                const SizedBox(width: 16),
                const Text(
                  '确认预约',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard(BookingProvider bookingProvider) {
    final shop = bookingProvider.selectedShop;
    final service = bookingProvider.selectedService;
    final stylist = bookingProvider.selectedStylist;
    final date = bookingProvider.selectedDate;
    final time = bookingProvider.selectedTime;

    // 格式化日期显示
    String formattedDate = '未选择';
    if (date != null && time != null) {
      try {
        final dateTime = DateTime.parse(date);
        formattedDate = '${dateTime.month}月${dateTime.day}日 $time';
      } catch (e) {
        formattedDate = '$date $time';
      }
    }

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Row(
            children: [
              Icon(
                LucideIcons.clipboardCheck,
                size: 20,
                color: Color(0xFFFF385C),
              ),
              SizedBox(width: 8),
              Text(
                '预约信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 信息列表
          _buildInfoRow('店铺名称', shop?.name ?? '-', LucideIcons.store),
          _buildInfoRow('服务项目', service?.name ?? '-', LucideIcons.scissors),
          _buildInfoRow('理发师', stylist?.name ?? '不指定', LucideIcons.user),
          _buildInfoRow('预约时间', formattedDate, LucideIcons.calendar),
          _buildInfoRow('服务时长', '约${service?.durationMinutes ?? 0}分钟', LucideIcons.clock),
          const SizedBox(height: 12),
          // 价格
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '服务价格',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '¥${service?.price.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF385C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Row(
            children: [
              Icon(
                LucideIcons.userRound,
                size: 20,
                color: Color(0xFFFF385C),
              ),
              SizedBox(width: 8),
              Text(
                '联系信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('姓名', user?.nickname ?? '用户', LucideIcons.user),
          _buildInfoRow('手机号', user?.phone ?? '-', LucideIcons.phone),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(
                LucideIcons.fileText,
                size: 20,
                color: Color(0xFFFF385C),
              ),
              const SizedBox(width: 8),
              const Text(
                '备注信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(可选)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '请输入备注信息，如特殊需求、发型要求等',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                LucideIcons.lightbulb,
                size: 18,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 8),
              Text(
                '温馨提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('请提前10分钟到店避免迟到影响服务'),
          _buildTipItem('如需取消预约，请提前2小时操作'),
          _buildTipItem('请保持手机畅通，方便店铺联系'),
          _buildTipItem('到店时请向工作人员出示预约码'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 8),
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFD97706),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD97706),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
          child: Row(
            children: [
              // 返回修改按钮
              Expanded(
                child: GestureDetector(
                  onTap: _isSubmitting ? null : () => context.pop(),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFFF385C),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '返回修改',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isSubmitting
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFFFF385C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 确认预约按钮
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _handleConfirmBooking,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: !_isSubmitting
                          ? const LinearGradient(
                              colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                            )
                          : null,
                      color: _isSubmitting ? const Color(0xFFD1D5DB) : null,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: !_isSubmitting
                          ? const [
                              BoxShadow(
                                color: Color(0x33FF385C),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '确认预约',
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
            ],
          ),
        ),
      ),
    );
  }
}
