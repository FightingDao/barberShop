import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 预约历史管理Provider
/// 管理用户的预约列表、取消预约等操作
class AppointmentProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService.instance;

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 获取待处理的预约
  List<Appointment> get pendingAppointments {
    return _appointments
        .where((appointment) => appointment.status == 'pending')
        .toList();
  }

  /// 获取已完成的预约
  List<Appointment> get completedAppointments {
    return _appointments
        .where((appointment) => appointment.status == 'completed')
        .toList();
  }

  /// 获取已取消的预约
  List<Appointment> get cancelledAppointments {
    return _appointments
        .where((appointment) => appointment.status == 'cancelled')
        .toList();
  }

  /// 获取预约列表
  ///
  /// [status] 预约状态（可选）：pending、completed、cancelled
  Future<void> fetchAppointments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _bookingService.getAppointments(status: status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch appointments error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取预约详情
  ///
  /// [appointmentId] 预约ID
  /// 返回预约详情，失败返回null
  Future<Appointment?> fetchAppointmentDetail(int appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointment = await _bookingService.getAppointmentDetail(appointmentId);
      _isLoading = false;
      notifyListeners();
      return appointment;
    } catch (e) {
      debugPrint('Fetch appointment detail error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 取消预约
  ///
  /// [appointmentId] 预约ID
  /// 返回是否取消成功
  Future<bool> cancelAppointment(int appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _bookingService.cancelAppointment(appointmentId);

      if (success) {
        // 更新本地预约列表中的状态
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          // 重新获取预约列表以确保数据同步
          await fetchAppointments();
        }
      } else {
        _errorMessage = '取消预约失败';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Cancel appointment error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 刷新预约列表
  Future<void> refresh() async {
    await fetchAppointments();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
