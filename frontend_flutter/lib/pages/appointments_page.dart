import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/models.dart';
import '../providers/appointment_provider.dart';

/// 我的预约页面 - 严格按照设计稿还原
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (!_hasLoaded && mounted) {
      try {
        context.read<AppointmentProvider>().fetchAppointments();
        _hasLoaded = true;
      } catch (e) {
        debugPrint('Load data error: $e');
      }
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    try {
      await context.read<AppointmentProvider>().refresh();
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  /// 格式化日期显示 (M月D日 周X)
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '未知时间';
    try {
      final date = DateTime.parse(dateStr);
      final month = date.month;
      final day = date.day;
      final weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      final weekDay = weekDays[date.weekday % 7];
      return '$month月$day日 $weekDay';
    } catch (e) {
      return dateStr;
    }
  }

  /// 格式化价格显示
  String _formatPrice(double? price) {
    if (price == null) return '';
    return '¥${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // 固定顶部导航栏
              _buildHeader(),
              // 固定Tab栏
              _buildTabBar(provider),
              // Tab内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(provider, 'pending'),
                    _buildList(provider, 'completed'),
                    _buildList(provider, 'cancelled'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
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
                '我的预约',
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
    );
  }

  Widget _buildTabBar(AppointmentProvider provider) {
    final pendingCount = provider.pendingAppointments.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('待服务'),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF385C),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: '已完成'),
          const Tab(text: '已取消'),
        ],
      ),
    );
  }

  Widget _buildList(AppointmentProvider provider, String status) {
    // 获取对应状态的预约
    List<Appointment> appointments = [];
    try {
      if (status == 'pending') {
        appointments = provider.pendingAppointments;
      } else if (status == 'completed') {
        appointments = provider.completedAppointments;
      } else if (status == 'cancelled') {
        appointments = provider.cancelledAppointments;
      }
    } catch (e) {
      debugPrint('Get appointments error: $e');
      appointments = [];
    }

    // 加载中
    if (provider.isLoading && appointments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF385C),
        ),
      );
    }

    // 错误
    if (provider.errorMessage != null && appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFFF385C),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? '加载失败',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  '重试',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 空列表
    if (appointments.isEmpty) {
      String emoji;
      String message;

      if (status == 'pending') {
        emoji = '📅';
        message = '暂无预约';
      } else if (status == 'cancelled') {
        emoji = '🚫';
        message = '暂无取消记录';
      } else {
        emoji = '📦';
        message = '暂无历史记录';
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
                  child: const Text(
                    '去预约',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // 列表
    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFFFF385C),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          try {
            return _buildAppointmentCard(appointments[index], status == 'pending');
          } catch (e) {
            debugPrint('Build card error: $e');
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAppointmentDetail(appointment),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店铺名称和状态
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.shop?.name ?? '未知店铺',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${appointment.service?.name ?? '未知服务'} | ${appointment.stylist?.name ?? '不指定理发师'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPending
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPending ? '待服务' : '已完成',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPending
                              ? const Color(0xFF059669)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 时间
                Row(
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(appointment.appointmentDate)} ${appointment.appointmentTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showAppointmentDetail(appointment),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              '查看详情',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCancelDialog(appointment),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFF385C),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                '取消预约',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFFF385C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示预约详情弹窗
  void _showAppointmentDetail(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  const Text(
                    '预约详情',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 预约码
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '预约码',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment.confirmationCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: appointment.confirmationCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('预约码已复制'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.copy,
                                size: 14,
                                color: Color(0xFFFF385C),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '复制',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFFF385C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 详细信息
                  _buildDetailRow(
                    LucideIcons.mapPin,
                    appointment.shop?.name ?? '未知店铺',
                    appointment.shop?.address,
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(
                    LucideIcons.scissors,
                    appointment.service?.name ?? '未知服务',
                    _formatPrice(appointment.service?.price),
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(
                    LucideIcons.user,
                    appointment.stylist?.name ?? '不指定理发师',
                    appointment.stylist?.title,
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildDetailRow(
                    LucideIcons.calendar,
                    _formatDate(appointment.appointmentDate),
                    appointment.appointmentTime,
                  ),
                  if (appointment.shop?.phone != null) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        // TODO: 实现拨打电话功能
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.phone,
                            size: 20,
                            color: Color(0xFFFF385C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '联系店铺：${appointment.shop!.phone}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFF385C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String? subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFFF385C),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 显示取消预约确认对话框
  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '确认取消预约？',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '取消后需要重新预约。如果您确定不需要此次服务，请点击确认取消。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '再想想',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleCancelAppointment(appointment);
            },
            child: const Text(
              '确认取消',
              style: TextStyle(
                color: Color(0xFFFF385C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理取消预约
  Future<void> _handleCancelAppointment(Appointment appointment) async {
    try {
      final success = await context
          .read<AppointmentProvider>()
          .cancelAppointment(appointment.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('预约已取消'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('取消失败，请稍后重试'),
            backgroundColor: Color(0xFFFF385C),
          ),
        );
      }
    } catch (e) {
      debugPrint('Cancel error: $e');
      if (mounted) {
        // 尝试解析错误消息
        String errorMessage = '操作失败';
        final errorStr = e.toString();

        // 如果错误信息包含 JSON 格式的响应，尝试提取 message
        if (errorStr.contains('"message"')) {
          try {
            final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorStr);
            if (messageMatch != null && messageMatch.groupCount >= 1) {
              errorMessage = messageMatch.group(1) ?? errorMessage;
            }
          } catch (_) {
            errorMessage = errorStr;
          }
        } else {
          errorMessage = errorStr;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFFF385C),
          ),
        );
      }
    }
  }
}
