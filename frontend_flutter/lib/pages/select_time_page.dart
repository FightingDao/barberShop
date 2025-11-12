import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 选择时间页
/// 选择预约日期和时间段
class SelectTimePage extends StatefulWidget {
  final int shopId;

  const SelectTimePage({super.key, required this.shopId});

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  List<DateItem> _dateList = [];
  String? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化日期列表（未来7天）
  void _initializeDateList() {
    final now = DateTime.now();
    final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      String label;
      if (i == 0) {
        label = '今天';
      } else if (i == 1) {
        label = '明天';
      } else {
        label = '${date.day}';
      }

      _dateList.add(DateItem(
        date: DateFormat('yyyy-MM-dd').format(date),
        label: label,
        weekday: weekdays[date.weekday % 7],
        displayDate: '${date.month}月${date.day}日',
      ));
    }

    // 默认选择今天
    _selectedDate = _dateList[0].date;
  }

  /// 初始化数据
  void _initializeData() {
    if (!_isInitialized) {
      final bookingProvider = context.read<BookingProvider>();
      if (_selectedDate != null) {
        bookingProvider.setDate(_selectedDate!);
        bookingProvider.fetchAvailableTimeSlots();
      }
      _isInitialized = true;
    }
  }

  /// 处理日期选择
  void _handleDateSelect(String date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null; // 切换日期时清空时间选择
    });

    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.setDate(date);
    bookingProvider.fetchAvailableTimeSlots();
  }

  /// 处理时间段选择
  void _handleTimeSlotSelect(TimeSlot timeSlot) {
    if (!timeSlot.isAvailable) return;

    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  /// 生成所有时间段
  List<TimeSlotItem> _generateAllTimeSlots(List<TimeSlot> availableSlots) {
    final slots = <TimeSlotItem>[];
    const startHour = 9;
    const endHour = 21;

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        if (hour == endHour && minute > 0) break;

        final time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final matchingSlot = availableSlots.firstWhere(
          (slot) => slot.startTime.substring(0, 5) == time,
          orElse: () => TimeSlot(
            date: _selectedDate ?? '',
            startTime: '$time:00',
            endTime: '',
            isAvailable: false,
          ),
        );

        slots.add(TimeSlotItem(
          time: time,
          slot: matchingSlot,
        ));
      }
    }

    return slots;
  }

  /// 按上午/下午分组
  Map<String, List<TimeSlotItem>> _groupTimeSlots(List<TimeSlotItem> allSlots) {
    final morning = <TimeSlotItem>[];
    final afternoon = <TimeSlotItem>[];

    for (final item in allSlots) {
      final hour = int.parse(item.time.split(':')[0]);
      if (hour < 12) {
        morning.add(item);
      } else {
        afternoon.add(item);
      }
    }

    return {'morning': morning, 'afternoon': afternoon};
  }

  /// 下一步
  void _handleNext() {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择时间段')),
      );
      return;
    }

    context.read<BookingProvider>().setTime(_selectedTimeSlot!.startTime);
    context.push('/booking/confirm/${widget.shopId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部导航
            _buildAppBar(),

            // 内容区域
            Expanded(
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, _) {
                  return _buildContent(bookingProvider);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 返回按钮
              GestureDetector(
                onTap: () => context.pop(),
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
                '选择时间',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingXs),
          Padding(
            padding: EdgeInsets.only(left: 32 + AppTheme.paddingMd),
            child: const Text(
              '请选择您方便的预约时间',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(BookingProvider bookingProvider) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      children: [
        // 日期选择
        _buildDateSelector(),
        const SizedBox(height: AppTheme.paddingLg),

        // 时间段选择
        if (_selectedDate != null) _buildTimeSlotSelector(bookingProvider),
      ],
    );
  }

  /// 构建日期选择器
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('📅', style: TextStyle(fontSize: 16)),
            SizedBox(width: AppTheme.paddingXs),
            Text(
              '选择日期',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMd,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _dateList.map((item) {
              final isSelected = _selectedDate == item.date;
              return GestureDetector(
                onTap: () => _handleDateSelect(item.date),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: AppTheme.paddingMd),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSm,
                    vertical: AppTheme.paddingMd,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingXs),
                      Text(
                        item.weekday,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeXs,
                          color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建时间段选择器
  Widget _buildTimeSlotSelector(BookingProvider bookingProvider) {
    // 加载中
    if (bookingProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingXxl),
          child: Column(
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: AppTheme.paddingLg),
              Text(
                '正在加载可用时间...',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSm,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 错误状态
    if (bookingProvider.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXxl),
        child: AppErrorWidget(
          message: bookingProvider.errorMessage!,
          onRetry: () => bookingProvider.fetchAvailableTimeSlots(),
        ),
      );
    }

    final allSlots = _generateAllTimeSlots(bookingProvider.availableTimeSlots);
    final groupedSlots = _groupTimeSlots(allSlots);
    final morningSlots = groupedSlots['morning']!;
    final afternoonSlots = groupedSlots['afternoon']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 上午时间段
        if (morningSlots.isNotEmpty) ...[
          const Text(
            '上午',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: AppTheme.paddingMd,
              mainAxisSpacing: AppTheme.paddingMd,
            ),
            itemCount: morningSlots.length,
            itemBuilder: (context, index) {
              return _buildTimeSlotButton(morningSlots[index]);
            },
          ),
          const SizedBox(height: AppTheme.paddingXxl),
        ],

        // 下午时间段
        if (afternoonSlots.isNotEmpty) ...[
          const Text(
            '下午',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: AppTheme.paddingMd,
              mainAxisSpacing: AppTheme.paddingMd,
            ),
            itemCount: afternoonSlots.length,
            itemBuilder: (context, index) {
              return _buildTimeSlotButton(afternoonSlots[index]);
            },
          ),
        ],
      ],
    );
  }

  /// 构建时间段按钮
  Widget _buildTimeSlotButton(TimeSlotItem item) {
    final isSelected = _selectedTimeSlot?.startTime.substring(0, 5) == item.time;
    final isAvailable = item.slot.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? () => _handleTimeSlotSelect(item.slot) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : isAvailable
                  ? AppTheme.bgPrimary
                  : AppTheme.bgTertiary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : isAvailable
                    ? AppTheme.borderLight
                    : AppTheme.bgTertiary,
          ),
        ),
        child: Center(
          child: Text(
            item.time,
            style: TextStyle(
              fontSize: AppTheme.fontSizeMd,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : isAvailable
                      ? AppTheme.textSecondary
                      : AppTheme.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    String displayText = '';
    if (_selectedDate != null && _selectedTimeSlot != null) {
      final dateItem = _dateList.firstWhere((d) => d.date == _selectedDate);
      displayText = '已选: ${dateItem.displayDate} ${_selectedTimeSlot!.startTime.substring(0, 5)}';
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: const Border(top: BorderSide(color: AppTheme.borderLight)),
        boxShadow: AppTheme.shadowLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayText.isNotEmpty) ...[
            Text(
              displayText,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSm,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMd),
          ],

          // 下一步按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedTimeSlot != null ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                ),
              ),
              child: const Text(
                '下一步',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 日期项
class DateItem {
  final String date; // yyyy-MM-dd
  final String label; // 今天/明天/日期
  final String weekday; // 周几
  final String displayDate; // 显示用日期

  DateItem({
    required this.date,
    required this.label,
    required this.weekday,
    required this.displayDate,
  });
}

/// 时间段项
class TimeSlotItem {
  final String time; // HH:mm
  final TimeSlot slot;

  TimeSlotItem({
    required this.time,
    required this.slot,
  });
}
