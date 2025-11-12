import '../models/models.dart';
import 'api_service.dart';

/// 店铺服务
/// 处理店铺相关的API调用
class ShopService {
  final ApiService _api = ApiService.instance;

  static ShopService? _instance;

  ShopService._();

  /// 获取单例实例
  static ShopService get instance {
    _instance ??= ShopService._();
    return _instance!;
  }

  /// 获取店铺列表
  ///
  /// [search] 搜索关键词（可选）
  /// [latitude] 纬度（可选，用于计算距离）
  /// [longitude] 经度（可选，用于计算距离）
  /// [radius] 搜索半径，单位：公里（可选）
  /// [page] 页码（可选）
  /// [limit] 每页数量（可选）
  /// 返回店铺列表
  Future<List<Shop>> getShops({
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (latitude != null) {
        queryParams['latitude'] = latitude;
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude;
      }
      if (radius != null) {
        queryParams['radius'] = radius;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _api.get<List<dynamic>>(
        '/api/v1/shops',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => Shop.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 获取店铺详情
  ///
  /// [shopId] 店铺ID
  /// 返回店铺详细信息
  Future<Shop?> getShopDetail(int shopId) async {
    try {
      final response = await _api.get<Shop>(
        '/api/v1/shops/$shopId',
        fromJson: (json) => Shop.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取店铺服务列表
  ///
  /// [shopId] 店铺ID
  /// 返回该店铺提供的所有服务列表
  Future<List<Service>> getShopServices(int shopId) async {
    try {
      final response = await _api.get<List<dynamic>>(
        '/api/v1/shops/$shopId/services',
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 获取店铺理发师列表
  ///
  /// [shopId] 店铺ID
  /// 返回该店铺的所有理发师列表
  Future<List<Stylist>> getShopStylists(int shopId) async {
    try {
      final response = await _api.get<List<dynamic>>(
        '/api/v1/shops/$shopId/stylists',
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((item) => Stylist.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 搜索店铺（便捷方法）
  ///
  /// [keyword] 搜索关键词
  /// 返回匹配的店铺列表
  Future<List<Shop>> searchShops(String keyword) async {
    return await getShops(search: keyword);
  }

  /// 获取附近的店铺（便捷方法）
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [radius] 搜索半径，单位：公里，默认10公里
  /// 返回附近的店铺列表，按距离排序
  Future<List<Shop>> getNearbyShops({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    return await getShops(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
