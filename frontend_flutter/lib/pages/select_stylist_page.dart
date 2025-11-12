import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 选择理发师页
/// 显示店铺的所有理发师供用户选择，或选择不指定
class SelectStylistPage extends StatefulWidget {
  final int shopId;

  const SelectStylistPage({super.key, required this.shopId});

  @override
  State<SelectStylistPage> createState() => _SelectStylistPageState();
}

class _SelectStylistPageState extends State<SelectStylistPage> {
  Object? _selectedStylist; // Can be Stylist or 'none'
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
      shopProvider.fetchStylists(widget.shopId);
      _isInitialized = true;
    }
  }

  /// 处理理发师选择
  void _handleSelectStylist(Object? selection) {
    setState(() {
      if (_selectedStylist == selection) {
        _selectedStylist = null;
      } else {
        _selectedStylist = selection;
      }
    });
  }

  /// 显示理发师详情
  void _showStylistDetail(Stylist stylist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StylistDetailSheet(stylist: stylist),
    );
  }

  /// 获取理发师状态信息
  Map<String, dynamic> _getStylistStatus(Stylist stylist) {
    switch (stylist.status) {
      case StylistStatus.active:
        return {
          'text': '可约',
          'color': AppTheme.success,
          'canSelect': true,
        };
      case StylistStatus.busy:
        return {
          'text': '已约满',
          'color': AppTheme.primary,
          'canSelect': false,
        };
      case StylistStatus.inactive:
        return {
          'text': '休息中',
          'color': AppTheme.textTertiary,
          'canSelect': false,
        };
    }
  }

  /// 下一步
  void _handleNext() {
    if (_selectedStylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择理发师')),
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();
    if (_selectedStylist == 'none') {
      bookingProvider.setStylist(null);
    } else {
      bookingProvider.setStylist(_selectedStylist as Stylist);
    }

    context.push('/booking/select-time/${widget.shopId}');
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
                    return const LoadingWidget(message: '加载理发师列表...');
                  }

                  // 错误状态
                  if (shopProvider.errorMessage != null) {
                    return AppErrorWidget(
                      message: shopProvider.errorMessage!,
                      onRetry: () => shopProvider.fetchStylists(widget.shopId),
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
            '选择理发师',
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
        // 预约信息提示
        if (bookingProvider.selectedShop != null && bookingProvider.selectedService != null)
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
                Text(
                  '服务：${bookingProvider.selectedService!.name} | ¥${bookingProvider.selectedService!.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

        // 不指定理发师选项
        _buildNoneOption(),
        const SizedBox(height: AppTheme.paddingLg),

        // 标题
        const Text(
          '或选择指定理发师',
          style: TextStyle(
            fontSize: AppTheme.fontSizeMd,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMd),

        // 理发师列表
        if (shopProvider.stylists.isEmpty)
          const EmptyWidget(
            message: '暂无理发师信息',
            icon: Icons.person_outline,
          )
        else
          ...shopProvider.stylists.map((stylist) {
            final isSelected = _selectedStylist is Stylist && (_selectedStylist as Stylist).id == stylist.id;
            final statusInfo = _getStylistStatus(stylist);
            return _buildStylistCard(stylist, isSelected, statusInfo);
          }).toList(),
      ],
    );
  }

  /// 构建"不指定理发师"选项
  Widget _buildNoneOption() {
    final isSelected = _selectedStylist == 'none';

    return GestureDetector(
      onTap: () => _handleSelectStylist('none'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLg),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 2,
            style: isSelected ? BorderStyle.solid : BorderStyle.solid,
          ),
          boxShadow: isSelected ? AppTheme.shadowPrimary : AppTheme.shadowSmall,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 28,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingLg),

                // 信息
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '不指定理发师',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppTheme.paddingSm),
                      Text(
                        '由店铺安排合适的理发师为您服务',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
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

  /// 构建理发师卡片
  Widget _buildStylistCard(Stylist stylist, bool isSelected, Map<String, dynamic> statusInfo) {
    final canSelect = statusInfo['canSelect'] as bool;

    return GestureDetector(
      onTap: canSelect ? () => _handleSelectStylist(stylist) : null,
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
        child: Opacity(
          opacity: canSelect ? 1.0 : 0.6,
          child: Stack(
            children: [
              Row(
                children: [
                  // 头像
                  GestureDetector(
                    onTap: canSelect ? () => _showStylistDetail(stylist) : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.bgTertiary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingLg),

                  // 理发师信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              stylist.name,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeLg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (stylist.level != null) ...[
                              const SizedBox(width: AppTheme.paddingSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.paddingSm,
                                  vertical: AppTheme.paddingXs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                child: Text(
                                  stylist.level!,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSizeXs,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (stylist.title != null) ...[
                          const SizedBox(height: AppTheme.paddingXs),
                          Text(
                            stylist.title!,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.paddingSm),
                        Row(
                          children: [
                            if (stylist.experience != null)
                              Text(
                                '🎓 ${stylist.experience}年经验',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeSm,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            if (stylist.specialty != null) ...[
                              const SizedBox(width: AppTheme.paddingMd),
                              Expanded(
                                child: Text(
                                  '✨ ${stylist.specialty}',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSizeSm,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 状态徽章
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSm,
                    vertical: AppTheme.paddingXs,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo['color'] as Color,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    statusInfo['text'] as String,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeXs,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    String displayText = '请选择理发师';
    if (_selectedStylist == 'none') {
      displayText = '已选：不指定理发师';
    } else if (_selectedStylist is Stylist) {
      displayText = '已选：${(_selectedStylist as Stylist).name}';
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
          // 选中信息
          Text(
            displayText,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // 下一步按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedStylist != null ? _handleNext : null,
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

/// 理发师详情弹窗
class _StylistDetailSheet extends StatelessWidget {
  final Stylist stylist;

  const _StylistDetailSheet({required this.stylist});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                // 头像和基本信息
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          boxShadow: AppTheme.shadowPrimary,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppTheme.paddingLg),
                      Text(
                        stylist.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeHuge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (stylist.level != null) ...[
                        const SizedBox(height: AppTheme.paddingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.paddingMd,
                            vertical: AppTheme.paddingXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            stylist.level!,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingXxl),

                // 详细信息
                if (stylist.title != null)
                  _buildInfoRow('职称', stylist.title!),
                if (stylist.experience != null)
                  _buildInfoRow('从业年限', '${stylist.experience}年'),
                if (stylist.specialty != null) ...[
                  const SizedBox(height: AppTheme.paddingLg),
                  const Text(
                    '擅长项目',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMd),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingLg),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Text(
                      stylist.specialty!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeBase,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                // 服务特色
                const SizedBox(height: AppTheme.paddingXxl),
                const Text(
                  '服务特色',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMd),
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• 注重细节，精益求精', style: TextStyle(height: 1.8)),
                      Text('• 根据顾客脸型推荐合适发型', style: TextStyle(height: 1.8)),
                      Text('• 专业造型建议和护理指导', style: TextStyle(height: 1.8)),
                    ],
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

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLg),
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.textTertiary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeMd,
              fontWeight: FontWeight.bold,
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
