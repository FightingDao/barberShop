import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 选择服务页
/// 显示店铺的所有服务供用户选择
class SelectServicePage extends StatefulWidget {
  final int shopId;

  const SelectServicePage({super.key, required this.shopId});

  @override
  State<SelectServicePage> createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  Service? _selectedService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化数据
  void _initializeData() {
    if (!_isInitialized) {
      final shopProvider = context.read<ShopProvider>();
      final bookingProvider = context.read<BookingProvider>();

      // 设置当前店铺
      if (shopProvider.selectedShop != null &&
          shopProvider.selectedShop!.id == widget.shopId) {
        bookingProvider.setShop(shopProvider.selectedShop!);
      }

      // 获取服务列表
      shopProvider.fetchServices(widget.shopId);
      _isInitialized = true;
    }
  }

  /// 处理服务选择
  void _handleSelectService(Service service) {
    setState(() {
      if (_selectedService?.id == service.id) {
        _selectedService = null;
      } else {
        _selectedService = service;
      }
    });
  }

  /// 显示服务详情
  void _showServiceDetail(Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceDetailSheet(service: service),
    );
  }

  /// 下一步
  void _handleNext() {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择服务项目')),
      );
      return;
    }

    context.read<BookingProvider>().setService(_selectedService!);
    context.push('/booking/select-stylist/${widget.shopId}');
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

            // 内容区域
            Expanded(
              child: Consumer2<ShopProvider, BookingProvider>(
                builder: (context, shopProvider, bookingProvider, _) {
                  // 加载中
                  if (shopProvider.isLoading) {
                    return const LoadingWidget(message: '加载服务列表...');
                  }

                  // 错误状态
                  if (shopProvider.errorMessage != null) {
                    return AppErrorWidget(
                      message: shopProvider.errorMessage!,
                      onRetry: () => shopProvider.fetchServices(widget.shopId),
                    );
                  }

                  // 空状态
                  if (shopProvider.services.isEmpty) {
                    return const EmptyWidget(
                      message: '暂无服务',
                      icon: Icons.content_cut,
                    );
                  }

                  return _buildContent(shopProvider, bookingProvider);
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
      child: Row(
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
            '选择服务',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(ShopProvider shopProvider, BookingProvider bookingProvider) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      children: [
        // 店铺信息
        if (bookingProvider.selectedShop != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLg),
            margin: const EdgeInsets.only(bottom: AppTheme.paddingLg),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookingProvider.selectedShop!.name,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSm),
                const Text(
                  '请选择需要的服务',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

        // 服务列表
        ...shopProvider.services.map((service) {
          final isSelected = _selectedService?.id == service.id;
          return _buildServiceCard(service, isSelected);
        }).toList(),
      ],
    );
  }

  /// 构建服务卡片
  Widget _buildServiceCard(Service service, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleSelectService(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.paddingLg),
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.shadowPrimary : AppTheme.shadowSmall,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 服务图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingLg),

                // 服务信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (service.description?.isNotEmpty == true) ...[
                        const SizedBox(height: AppTheme.paddingSm),
                        Text(
                          (service.description?.length ?? 0) > 30
                              ? '${service.description!.substring(0, 30)}...'
                              : service.description ?? '',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSm,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.paddingSm),
                      Text(
                        '⏱ ${service.durationMinutes}分钟',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 价格和详情按钮
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${service.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXl,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSm),
                    GestureDetector(
                      onTap: () => _showServiceDetail(service),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingSm,
                          vertical: AppTheme.paddingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              '详情',
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeSm,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 选中标记
            if (isSelected)
              Positioned(
                top: -1,
                right: -1,
                child: CustomPaint(
                  painter: _CornerTrianglePainter(),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4, right: 4),
                        child: Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
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
          // 选中信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedService != null
                    ? '已选：${_selectedService!.name}'
                    : '请选择服务',
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeBase,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (_selectedService != null)
                Text(
                  '¥${_selectedService!.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXl,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // 下一步按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedService != null ? _handleNext : null,
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

/// 服务详情弹窗
class _ServiceDetailSheet extends StatelessWidget {
  final Service service;

  const _ServiceDetailSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      child: Column(
        children: [
          // 拖动条
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppTheme.paddingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.paddingXxl),
              children: [
                // 标题
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeHuge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingLg),

                // 价格和时长
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '服务价格',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeBase,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          Text(
                            '¥${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeHuge,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '服务时长',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeBase,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          Text(
                            '约 ${service.durationMinutes} 分钟',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 服务说明
                if (service.description?.isNotEmpty == true) ...[
                  const SizedBox(height: AppTheme.paddingXxl),
                  const Text(
                    '服务说明',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMd),
                  Text(
                    service.description!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeBase,
                      color: AppTheme.textSecondary,
                      height: 1.8,
                    ),
                  ),
                ],

                // 适用人群
                const SizedBox(height: AppTheme.paddingXxl),
                const Text(
                  '适用人群',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMd),
                Text(
                  '适合所有需要${service.name}服务的顾客',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.textSecondary,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingXxl),

                // 知道了按钮
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      ),
                    ),
                    child: const Text(
                      '知道了',
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
          ),
        ],
      ),
    );
  }
}

/// 右上角三角形画笔
class _CornerTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
