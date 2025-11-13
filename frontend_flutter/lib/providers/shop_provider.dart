import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 店铺数据管理Provider
/// 管理店铺列表、详情、服务、理发师等数据
class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService.instance;

  List<Shop> _shops = [];
  Shop? _selectedShop;
  List<Service> _services = [];
  List<Stylist> _stylists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Shop> get shops => _shops;
  Shop? get selectedShop => _selectedShop;
  List<Service> get services => _services;
  List<Stylist> get stylists => _stylists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 获取店铺列表
  ///
  /// [search] 搜索关键词（可选）
  Future<void> fetchShops({String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _shops = await _shopService.getShops(search: search);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch shops error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取店铺详情
  ///
  /// [shopId] 店铺ID
  Future<void> fetchShopDetail(int shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final shop = await _shopService.getShopDetail(shopId);
      if (shop != null) {
        _selectedShop = shop;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch shop detail error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取店铺服务列表
  ///
  /// [shopId] 店铺ID
  Future<void> fetchServices(int shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await _shopService.getShopServices(shopId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch services error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取店铺理发师列表
  ///
  /// [shopId] 店铺ID
  Future<void> fetchStylists(int shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stylists = await _shopService.getShopStylists(shopId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch stylists error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 直接获取店铺理发师列表（不修改状态）
  ///
  /// [shopId] 店铺ID
  /// 返回理发师列表
  Future<List<Stylist>> getShopStylists(int shopId) async {
    return await _shopService.getShopStylists(shopId);
  }

  /// 设置选中的店铺
  void setSelectedShop(Shop shop) {
    _selectedShop = shop;
    notifyListeners();
  }

  /// 清除选中的店铺
  void clearSelectedShop() {
    _selectedShop = null;
    _services = [];
    _stylists = [];
    notifyListeners();
  }

  /// 搜索店铺
  ///
  /// [keyword] 搜索关键词
  Future<void> searchShops(String keyword) async {
    await fetchShops(search: keyword);
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
