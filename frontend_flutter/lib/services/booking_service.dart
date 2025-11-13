import '../models/models.dart';
import 'api_service.dart';

/// 预约服务
/// 处理预约相关的API调用
class BookingService {
  final ApiService _api = ApiService.instance;

  static BookingService? _instance;

  BookingService._();

  /// 获取单例实例
  static BookingService get instance {
    _instance ??= BookingService._();
    return _instance!;
  }

  /// 获取可用时间段
  ///
  /// [shopId] 店铺ID
  /// [serviceId] 服务ID
  /// [date] 日期，格式：YYYY-MM-DD
  /// [stylistId] 理发师ID（可选）
  /// 返回该日期可用的时间段列表
  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int shopId,
    required int serviceId,
    required String date,
    int? stylistId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'shop_id': shopId,
        'service_id': serviceId,
        'date': date,
      };

      if (stylistId != null) {
        queryParams['stylist_id'] = stylistId;
      }

      final response = await _api.get<List<dynamic>>(
        '/api/v1/availability',
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => TimeSlot.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 创建预约
  ///
  /// [shopId] 店铺ID
  /// [serviceId] 服务ID
  /// [appointmentDate] 预约日期，格式：YYYY-MM-DD
  /// [appointmentTime] 预约时间，格式：HH:mm
  /// [stylistId] 理发师ID（可选）
  /// [notes] 备注（可选）
  /// 返回创建的预约信息
  Future<Appointment?> createAppointment({
    required int shopId,
    required int serviceId,
    required String appointmentDate,
    required String appointmentTime,
    int? stylistId,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'shop_id': shopId,
        'service_id': serviceId,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
      };

      if (stylistId != null) {
        data['stylist_id'] = stylistId;
      }
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      final response = await _api.post<Appointment>(
        '/api/v1/appointments',
        data: data,
        fromJson: (json) => Appointment.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户预约列表
  ///
  /// [status] 预约状态（可选）：pending、completed、cancelled
  /// [page] 页码（可选）
  /// [limit] 每页数量（可选）
  /// 返回用户的预约列表
  Future<List<Appointment>> getAppointments({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _api.get<List<dynamic>>(
        '/api/v1/appointments',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 获取预约详情
  ///
  /// [appointmentId] 预约ID
  /// 返回预约的详细信息
  Future<Appointment?> getAppointmentDetail(int appointmentId) async {
    try {
      final response = await _api.get<Appointment>(
        '/api/v1/appointments/$appointmentId',
        fromJson: (json) => Appointment.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 取消预约
  ///
  /// [appointmentId] 预约ID
  /// 返回是否取消成功
  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      final response = await _api.put(
        '/api/v1/appointments/$appointmentId/cancel',
      );

      return response.success;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取待处理的预约（便捷方法）
  ///
  /// 返回状态为pending的预约列表
  Future<List<Appointment>> getPendingAppointments() async {
    return await getAppointments(status: 'pending');
  }

  /// 获取已完成的预约（便捷方法）
  ///
  /// 返回状态为completed的预约列表
  Future<List<Appointment>> getCompletedAppointments() async {
    return await getAppointments(status: 'completed');
  }

  /// 获取已取消的预约（便捷方法）
  ///
  /// 返回状态为cancelled的预约列表
  Future<List<Appointment>> getCancelledAppointments() async {
    return await getAppointments(status: 'cancelled');
  }
}
