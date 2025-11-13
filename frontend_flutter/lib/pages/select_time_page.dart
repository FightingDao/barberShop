import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/booking_provider.dart';
import '../providers/shop_provider.dart';
import '../services/booking_service.dart';
import '../models/time_slot.dart';

/// 选择时间页面 - 严格按照设计稿还原
class SelectTimePage extends StatefulWidget {
  final int shopId;

  const SelectTimePage({super.key, required this.shopId});

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  List<DateItem> _dateList = [];
  String? _selectedDate;
  String? _selectedTime;
  bool _isInitialized = false;

  // 可用时间段数据
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  String? _slotsErrorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDateList();
    // 默认选择明天和14:00
    if (_dateList.length > 1) {
      _selectedDate = _dateList[1].id;
      _selectedTime = '14:00';
    }
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

      final month = date.month;
      final day = date.day;
      final weekday = weekdays[date.weekday % 7];

      // 生成 YYYY-MM-DD 格式的日期字符串
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      _dateList.add(DateItem(
        id: dateStr,
        label: label,
        weekday: weekday,
        fullDate: '$month月$day日',
      ));
    }
  }

  /// 初始化数据
  void _initializeData() {
    if (!_isInitialized) {
      final shopProvider = context.read<ShopProvider>();
      final bookingProvider = context.read<BookingProvider>();

      // 设置当前店铺（如果还未设置）
      if (shopProvider.selectedShop != null &&
          shopProvider.selectedShop!.id == widget.shopId) {
        bookingProvider.setShop(shopProvider.selectedShop!);
      }

      _isInitialized = true;

      // 加载默认日期的可用时间段
      if (_selectedDate != null) {
        _loadAvailability(_selectedDate!);
      }
    }
  }

  /// 加载指定日期的可用时间段
  Future<void> _loadAvailability(String date) async {
    final bookingProvider = context.read<BookingProvider>();

    // 检查必要的数据是否存在
    if (bookingProvider.selectedShop == null ||
        bookingProvider.selectedService == null) {
      setState(() {
        _slotsErrorMessage = '缺少必要的预约信息';
        _isLoadingSlots = false;
        _availableSlots = [];
      });
      return;
    }

    setState(() {
      _isLoadingSlots = true;
      _slotsErrorMessage = null;
    });

    try {
      final slots = await BookingService.instance.getAvailableTimeSlots(
        shopId: bookingProvider.selectedShop!.id,
        serviceId: bookingProvider.selectedService!.id,
        date: date,
        stylistId: bookingProvider.selectedStylist?.id,
      );

      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _slotsErrorMessage = '加载时间段失败: ${e.toString()}';
        _isLoadingSlots = false;
        _availableSlots = [];
      });
    }
  }

  /// 生成上午时间段 09:00 - 11:30
  List<TimeSlot> _generateMorningSlots() {
    return _availableSlots.where((slot) {
      final hour = int.tryParse(slot.startTime.split(':')[0]) ?? 0;
      return hour >= 9 && hour < 12;
    }).toList();
  }

  /// 生成下午时间段 12:00 - 20:30
  List<TimeSlot> _generateAfternoonSlots() {
    return _availableSlots.where((slot) {
      final hour = int.tryParse(slot.startTime.split(':')[0]) ?? 0;
      return hour >= 12 && hour <= 20;
    }).toList();
  }

  /// 检查时间段是否可用
  bool _isSlotAvailable(String time) {
    final slot = _availableSlots.firstWhere(
      (slot) => slot.startTime == time,
      orElse: () => TimeSlot(
        date: '',
        startTime: '',
        endTime: '',
        isAvailable: false,
      ),
    );
    return slot.isAvailable;
  }

  /// 处理日期选择
  void _handleDateSelect(String dateId) {
    setState(() {
      _selectedDate = dateId;
      _selectedTime = null; // 清除之前选择的时间
    });
    // 加载新日期的可用时间段
    _loadAvailability(dateId);
  }

  /// 处理时间选择
  void _handleTimeSelect(String time) {
    if (!_isSlotAvailable(time)) return;

    setState(() {
      _selectedTime = time;
    });
  }

  /// 下一步
  void _handleNext() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择日期和时间')),
      );
      return;
    }

    // 设置选中的日期和时间到 BookingProvider
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.setDateTime(_selectedDate!, _selectedTime!);

    context.push('/booking/confirm/${widget.shopId}');
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateObj = _dateList.firstWhere(
      (d) => d.id == _selectedDate,
      orElse: () => _dateList[0],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 主内容区域
          CustomScrollView(
            slivers: [
              // 顶部间距（为固定header留空间）
              const SliverToBoxAdapter(
                child: SizedBox(height: 56),
              ),
              // 提示文字
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Text(
                    '请选择您方便的预约时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              // 日期选择器
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildDateSelector(),
                ),
              ),
              // 加载指示器或错误信息
              if (_isLoadingSlots)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF385C),
                      ),
                    ),
                  ),
                )
              else if (_slotsErrorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _slotsErrorMessage!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                // 上午时间段
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _buildTimeSection('上午', _generateMorningSlots()),
                  ),
                ),
                // 下午时间段
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                    child: _buildTimeSection('下午', _generateAfternoonSlots()),
                  ),
                ),
              ],
            ],
          ),
          // 固定顶部导航栏
          _buildHeader(),
          // 固定底部操作栏
          _buildBottomBar(selectedDateObj),
        ],
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
                  '选择时间',
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

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dateList.length,
        itemBuilder: (context, index) {
          final date = _dateList[index];
          final isSelected = _selectedDate == date.id;

          return GestureDetector(
            onTap: () => _handleDateSelect(date.id),
            child: Container(
              width: 64,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF385C) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x33FF385C),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.weekday,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSection(String title, List<TimeSlot> timeSlots) {
    if (timeSlots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '暂无可用时间段',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final time = slot.startTime;
            final isAvailable = slot.isAvailable;
            final isSelected = _selectedTime == time;

            return GestureDetector(
              onTap: () => _handleTimeSelect(time),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF385C)
                      : isAvailable
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x33FF385C),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                              ? const Color(0xFF111827)
                              : const Color(0xFFD1D5DB),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(DateItem selectedDateObj) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedTime != null) ...[
                Text(
                  '已选：${selectedDateObj.fullDate} $_selectedTime',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              GestureDetector(
                onTap: _handleNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _selectedTime != null
                        ? const LinearGradient(
                            colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                          )
                        : null,
                    color: _selectedTime != null ? null : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _selectedTime != null
                        ? const [
                            BoxShadow(
                              color: Color(0x33FF385C),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: const Center(
                    child: Text(
                      '下一步',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

/// 日期项
class DateItem {
  final String id; // M-d
  final String label; // 今天/明天/日期
  final String weekday; // 周几
  final String fullDate; // M月d日

  DateItem({
    required this.id,
    required this.label,
    required this.weekday,
    required this.fullDate,
  });
}
