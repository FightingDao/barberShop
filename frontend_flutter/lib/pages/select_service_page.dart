import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/shop_provider.dart';
import '../providers/booking_provider.dart';
import '../models/models.dart';

/// 选择服务页面 - 严格按照设计稿还原
class SelectServicePage extends StatefulWidget {
  final int shopId;

  const SelectServicePage({super.key, required this.shopId});

  @override
  State<SelectServicePage> createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  int? _selectedServiceId;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!_isInitialized) {
      final shopProvider = context.read<ShopProvider>();
      final bookingProvider = context.read<BookingProvider>();

      // 设置当前店铺
      if (shopProvider.selectedShop != null &&
          shopProvider.selectedShop!.id == widget.shopId) {
        bookingProvider.setShop(shopProvider.selectedShop!);
      }

      // 从API获取服务列表
      await _loadServices();

      _isInitialized = true;
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shopProvider = context.read<ShopProvider>();
      await shopProvider.fetchServices(widget.shopId);
      if (mounted) {
        setState(() {
          _services = shopProvider.services;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load services error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载服务列表失败';
          _isLoading = false;
        });
      }
    }
  }

  void _handleSelectService(int serviceId) {
    setState(() {
      _selectedServiceId = serviceId;
    });
  }

  void _showServiceDetail(Service service) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '¥${service.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '约${service.durationMinutes}分钟',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
              if (service.description != null && service.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  service.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择服务项目')),
      );
      return;
    }

    // 获取选中的服务
    final selectedService = _services.firstWhere(
      (s) => s.id == _selectedServiceId,
      orElse: () => _services.first,
    );

    // 设置到BookingProvider
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.setService(selectedService);

    context.push('/booking/select-stylist/${widget.shopId}');
  }

  @override
  Widget build(BuildContext context) {
    Service? selectedService;
    try {
      if (_selectedServiceId != null) {
        selectedService = _services.firstWhere(
          (s) => s.id == _selectedServiceId,
        );
      }
    } catch (e) {
      // Service not found
      selectedService = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    '请选择您需要的服务项目',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              // 加载或错误状态
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF385C),
                      ),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFFF385C),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadServices,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF385C),
                            ),
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // 服务列表
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = _services[index];
                        final isSelected = _selectedServiceId == service.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => _handleSelectService(service.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF385C)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 图标
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFF385C)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getServiceIcon(service.name),
                                      size: 28,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 服务信息
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                service.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFFF385C),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  LucideIcons.check,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (service.description != null && service.description!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            service.description!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '¥${service.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF385C),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '约${service.durationMinutes}分钟',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () => _showServiceDetail(service),
                                              child: const Icon(
                                                LucideIcons.info,
                                                size: 20,
                                                color: Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _services.length,
                    ),
                  ),
                ),
            ],
          ),
          // 固定顶部导航栏
          _buildHeader(),
          // 固定底部操作栏
          _buildBottomBar(selectedService),
        ],
      ),
    );
  }

  // 根据服务名称返回对应的图标
  IconData _getServiceIcon(String serviceName) {
    final lowerName = serviceName.toLowerCase();
    if (lowerName.contains('理发') || lowerName.contains('剪发') || lowerName.contains('男士')) {
      return LucideIcons.scissors;
    } else if (lowerName.contains('烫发') || lowerName.contains('烫')) {
      return LucideIcons.flame;
    } else if (lowerName.contains('染发') || lowerName.contains('染')) {
      return LucideIcons.palette;
    } else if (lowerName.contains('护理') || lowerName.contains('养护')) {
      return LucideIcons.sparkles;
    } else if (lowerName.contains('造型') || lowerName.contains('设计')) {
      return LucideIcons.wand;
    } else if (lowerName.contains('洗') || lowerName.contains('清洁')) {
      return LucideIcons.droplet;
    } else {
      return LucideIcons.scissors;
    }
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
                  '选择服务',
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

  Widget _buildBottomBar(Service? selectedService) {
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
              if (selectedService != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已选：${selectedService.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '¥${selectedService.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF385C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              GestureDetector(
                onTap: _handleNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _selectedServiceId != null
                        ? const LinearGradient(
                            colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                          )
                        : null,
                    color: _selectedServiceId != null
                        ? null
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _selectedServiceId != null
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
