import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 我的预约页
/// 显示用户的所有预约记录，支持取消预约
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 初始化数据
  void _initializeData() {
    if (!_isInitialized) {
      final appointmentProvider = context.read<AppointmentProvider>();
      appointmentProvider.fetchAppointments();
      _isInitialized = true;
    }
  }

  /// 刷新数据
  Future<void> _handleRefresh() async {
    final appointmentProvider = context.read<AppointmentProvider>();
    await appointmentProvider.refresh();
  }

  /// 取消预约
  Future<void> _handleCancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消'),
        content: const Text('确定要取消这个预约吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('返回'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('确认取消', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final appointmentProvider = context.read<AppointmentProvider>();
    final success = await appointmentProvider.cancelAppointment(appointment.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('预约已取消')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.errorMessage ?? '取消失败'),
          backgroundColor: AppTheme.error,
        ),
      );
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

            // Tab 标签栏
            _buildTabBar(),

            // 内容区域
            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, appointmentProvider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentList(
                        appointmentProvider.pendingAppointments,
                        appointmentProvider.isLoading,
                        appointmentProvider.errorMessage,
                        showCancel: true,
                      ),
                      _buildAppointmentList(
                        appointmentProvider.completedAppointments,
                        appointmentProvider.isLoading,
                        appointmentProvider.errorMessage,
                      ),
                      _buildAppointmentList(
                        appointmentProvider.cancelledAppointments,
                        appointmentProvider.isLoading,
                        appointmentProvider.errorMessage,
                      ),
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
            onTap: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
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
            '我的预约',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建Tab栏
  Widget _buildTabBar() {
    return Container(
      color: AppTheme.bgPrimary,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: AppTheme.fontSizeMd,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: '待服务'),
          Tab(text: '已完成'),
          Tab(text: '已取消'),
        ],
      ),
    );
  }

  /// 构建预约列表
  Widget _buildAppointmentList(
    List<Appointment> appointments,
    bool isLoading,
    String? errorMessage, {
    bool showCancel = false,
  }) {
    if (isLoading) {
      return const LoadingWidget(message: '加载预约列表...');
    }

    if (errorMessage != null) {
      return AppErrorWidget(message: errorMessage, onRetry: _handleRefresh);
    }

    if (appointments.isEmpty) {
      return const EmptyWidget(message: '暂无预约记录', icon: Icons.event_busy);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment, showCancel);
        },
      ),
    );
  }

  /// 构建预约卡片
  Widget _buildAppointmentCard(Appointment appointment, bool showCancel) {
    final shop = appointment.shop;
    final service = appointment.service;
    final stylist = appointment.stylist;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：状态和时间
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMd),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                topRight: Radius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(appointment.status),
                      size: 16,
                      color: _getStatusColor(appointment.status),
                    ),
                    const SizedBox(width: AppTheme.paddingSm),
                    Text(
                      _getStatusText(appointment.status),
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSm,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                  ],
                ),
                Text(
                  _buildDateTimeLabel(
                    appointment.appointmentDate,
                    appointment.appointmentTime,
                  ),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店铺信息
                Row(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.paddingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop?.name ?? '未知店铺',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (shop?.address != null)
                            Text(
                              shop!.address,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeSm,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingMd),

                // 服务信息
                Row(
                  children: [
                    const Icon(
                      Icons.content_cut,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.paddingSm),
                    Expanded(
                      child: Text(
                        service?.name ?? '未知服务',
                        style: const TextStyle(fontSize: AppTheme.fontSizeBase),
                      ),
                    ),
                    Text(
                      _formatPrice(service?.price),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeMd,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),

                // 理发师信息
                if (stylist != null) ...[
                  const SizedBox(height: AppTheme.paddingSm),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.paddingSm),
                      Text(
                        stylist.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // 备注
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingMd),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSm),
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note,
                          size: 16,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: AppTheme.paddingSm),
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 取消按钮
                if (showCancel) ...[
                  const SizedBox(height: AppTheme.paddingMd),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => _handleCancelAppointment(appointment),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSm,
                          ),
                        ),
                      ),
                      child: const Text(
                        '取消预约',
                        style: TextStyle(
                          color: AppTheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.textTertiary;
      default:
        return AppTheme.textSecondary;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取状态文本
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待服务';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知状态';
    }
  }

  String _buildDateTimeLabel(String? date, String? time) {
    final safeDate = date ?? '';
    if (time == null || time.isEmpty) {
      return safeDate;
    }

    final normalized = time.length >= 5 ? time.substring(0, 5) : time;
    return '$safeDate $normalized';
  }

  String _formatPrice(double? price) {
    if (price == null) return '¥0';
    return '¥${price.toStringAsFixed(0)}';
  }
}
