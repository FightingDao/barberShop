import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 预约流程管理Provider
/// 管理整个预约流程中的状态：选择服务、理发师、时间等
class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService.instance;

  Shop? _selectedShop;
  Service? _selectedService;
  Stylist? _selectedStylist;
  String? _selectedDate;
  String? _selectedTime;
  List<TimeSlot> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  Shop? get selectedShop => _selectedShop;
  Service? get selectedService => _selectedService;
  Stylist? get selectedStylist => _selectedStylist;
  String? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  List<TimeSlot> get availableTimeSlots => _availableTimeSlots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 检查是否可以创建预约
  bool get canCreateAppointment {
    return _selectedShop != null &&
        _selectedService != null &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  /// 设置选中的店铺
  void setShop(Shop shop) {
    _selectedShop = shop;
    notifyListeners();
  }

  /// 设置选中的服务
  void setService(Service service) {
    _selectedService = service;
    // 清除之前选择的时间，因为服务变了需要重新选择
    _selectedDate = null;
    _selectedTime = null;
    _availableTimeSlots = [];
    notifyListeners();
  }

  /// 设置选中的理发师（可选）
  void setStylist(Stylist? stylist) {
    _selectedStylist = stylist;
    // 清除之前选择的时间，因为理发师变了需要重新选择
    _selectedDate = null;
    _selectedTime = null;
    _availableTimeSlots = [];
    notifyListeners();
  }

  /// 设置选中的日期
  void setDate(String date) {
    _selectedDate = date;
    _selectedTime = null; // 清除之前选择的时间
    notifyListeners();
  }

  /// 设置选中的时间
  void setTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  /// 设置日期和时间
  void setDateTime(String date, String time) {
    _selectedDate = date;
    _selectedTime = time;
    notifyListeners();
  }

  /// 获取可用时间段
  Future<void> fetchAvailableTimeSlots() async {
    if (_selectedShop == null || _selectedService == null || _selectedDate == null) {
      _errorMessage = '请先选择店铺、服务和日期';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableTimeSlots = await _bookingService.getAvailableTimeSlots(
        shopId: _selectedShop!.id,
        serviceId: _selectedService!.id,
        date: _selectedDate!,
        stylistId: _selectedStylist?.id,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch available time slots error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建预约
  ///
  /// [notes] 备注（可选）
  /// 返回创建的预约，失败返回null
  Future<Appointment?> createAppointment({String? notes}) async {
    if (!canCreateAppointment) {
      _errorMessage = '请完成所有选择后再创建预约';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await _bookingService.createAppointment(
        shopId: _selectedShop!.id,
        serviceId: _selectedService!.id,
        appointmentDate: _selectedDate!,
        appointmentTime: _selectedTime!,
        stylistId: _selectedStylist?.id,
        notes: notes,
      );

      _isLoading = false;

      if (appointment == null) {
        _errorMessage = '创建预约失败';
      }
      // 注意：预约成功后不立即清空状态，由成功页面手动清空

      notifyListeners();
      return appointment;
    } catch (e) {
      debugPrint('Create appointment error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 清空所有选择状态
  void clear() {
    _selectedShop = null;
    _selectedService = null;
    _selectedStylist = null;
    _selectedDate = null;
    _selectedTime = null;
    _availableTimeSlots = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
