import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/appointment_provider.dart';
import '../widgets/widgets.dart';

/// 我的预约页面 - 完全重写版本
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

    // 安全地加载数据
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('我的预约'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: '待服务'),
            Tab(text: '已完成'),
            Tab(text: '已取消'),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider, 'pending'),
              _buildList(provider, 'completed'),
              _buildList(provider, 'cancelled'),
            ],
          );
        },
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
      } else {
        appointments = provider.cancelledAppointments;
      }
    } catch (e) {
      debugPrint('Get appointments error: $e');
      appointments = [];
    }

    // 加载中
    if (provider.isLoading && appointments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 错误
    if (provider.errorMessage != null && appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? '加载失败',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空列表
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 列表
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          try {
            return _buildCard(appointments[index], status == 'pending');
          } catch (e) {
            debugPrint('Build card error: $e');
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildCard(Appointment appointment, bool showCancel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态和时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatus(appointment.status),
                Text(
                  _formatDate(appointment.appointmentDate, appointment.appointmentTime),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 店铺
            _buildInfoRow(
              Icons.store,
              appointment.shop?.name ?? '未知店铺',
              appointment.shop?.address,
            ),
            const SizedBox(height: 12),

            // 服务
            _buildInfoRow(
              Icons.content_cut,
              appointment.service?.name ?? '未知服务',
              _formatPrice(appointment.service?.price),
            ),

            // 理发师
            if (appointment.stylist != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.person,
                appointment.stylist!.name,
                appointment.stylist!.title,
              ),
            ],

            // 备注
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16, color: AppTheme.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 取消按钮
            if (showCancel) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                  ),
                  child: const Text(
                    '取消预约',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color color = AppTheme.textSecondary;
    IconData icon = Icons.help_outline;
    String text = '未知';

    if (status == 'pending') {
      color = AppTheme.warning;
      icon = Icons.schedule;
      text = '待服务';
    } else if (status == 'completed') {
      color = AppTheme.success;
      icon = Icons.check_circle;
      text = '已完成';
    } else if (status == 'cancelled') {
      color = AppTheme.textTertiary;
      icon = Icons.cancel;
      text = '已取消';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getEmptyMessage(String status) {
    if (status == 'pending') return '暂无待服务的预约';
    if (status == 'completed') return '暂无已完成的预约';
    return '暂无已取消的预约';
  }

  String _formatDate(String? date, String? time) {
    if (date == null || date.isEmpty) return '未知时间';
    if (time == null || time.isEmpty) return date;

    String t = time;
    if (t.length > 5) t = t.substring(0, 5);

    return '$date $t';
  }

  String _formatPrice(double? price) {
    if (price == null) return '';
    return '¥${price.toInt()}';
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消'),
        content: const Text('确定要取消这个预约吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await context.read<AppointmentProvider>().cancelAppointment(appointment.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('预约已取消')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('取消失败，请稍后重试'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Cancel error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
