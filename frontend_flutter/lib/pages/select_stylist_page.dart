import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../providers/shop_provider.dart';
import '../providers/booking_provider.dart';
import '../models/models.dart';

/// 选择理发师页面 - 严格按照设计稿还原
class SelectStylistPage extends StatefulWidget {
  final int shopId;

  const SelectStylistPage({super.key, required this.shopId});

  @override
  State<SelectStylistPage> createState() => _SelectStylistPageState();
}

class _SelectStylistPageState extends State<SelectStylistPage> {
  int? _selectedStylistId; // null 表示"不指定理发师"，-1 表示未选择
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  List<Stylist> _stylists = [];

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

      // 设置当前店铺（如果还未设置）
      if (shopProvider.selectedShop != null &&
          shopProvider.selectedShop!.id == widget.shopId) {
        bookingProvider.setShop(shopProvider.selectedShop!);
      }

      // 从API获取理发师列表
      await _loadStylists();

      _isInitialized = true;
    }
  }

  Future<void> _loadStylists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stylists = await context.read<ShopProvider>().getShopStylists(widget.shopId);
      if (mounted) {
        setState(() {
          _stylists = stylists;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load stylists error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载理发师列表失败';
          _isLoading = false;
        });
      }
    }
  }

  void _handleSelectStylist(int? stylistId, StylistStatus? status) {
    // 如果是已约满状态，不允许选择
    if (status == StylistStatus.busy) return;

    setState(() {
      _selectedStylistId = stylistId;
    });
  }

  void _showStylistDetail(Stylist stylist) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '理发师详情',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 头像和基本信息
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF472B6), Color(0xFFFB7185)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: stylist.avatarUrl != null && stylist.avatarUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              stylist.avatarUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stylist.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (stylist.title != null)
                          Text(
                            stylist.title!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(stylist.status),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 从业经验
              if (stylist.experienceYears != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.award,
                        size: 20,
                        color: Color(0xFFFF385C),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '从业经验：${stylist.experienceYears}年',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 擅长项目
              if (stylist.specialties != null && stylist.specialties!.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 20,
                        color: Color(0xFFFF385C),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '擅长项目',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stylist.specialties!.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StylistStatus status) {
    String text;
    Color bgColor;
    Color textColor;

    switch (status) {
      case StylistStatus.active:
        text = '可约';
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF059669);
        break;
      case StylistStatus.busy:
        text = '已约满';
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case StylistStatus.inactive:
        text = '休息中';
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleNext() {
    if (_selectedStylistId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择理发师')),
      );
      return;
    }

    final bookingProvider = context.read<BookingProvider>();

    if (_selectedStylistId == null) {
      // 用户选择"不指定理发师"
      bookingProvider.setStylist(null);
    } else {
      // 获取选中的理发师
      final selectedStylist = _stylists.firstWhere(
        (s) => s.id == _selectedStylistId,
        orElse: () => _stylists.first,
      );

      bookingProvider.setStylist(selectedStylist);
    }

    context.push('/booking/select-time/${widget.shopId}');
  }

  @override
  Widget build(BuildContext context) {
    String selectedName = '';
    if (_selectedStylistId == null) {
      selectedName = '不指定理发师';
    } else if (_selectedStylistId != -1) {
      try {
        final stylist = _stylists.firstWhere((s) => s.id == _selectedStylistId);
        selectedName = stylist.name;
      } catch (e) {
        // Stylist not found
        selectedName = '';
      }
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
                    '选择您喜欢的理发师，或由系统自动分配',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              // "不指定理发师"选项
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildNoPreferenceCard(),
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
                            onPressed: _loadStylists,
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
              // 理发师列表
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final stylist = _stylists[index];
                        final isSelected = _selectedStylistId == stylist.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildStylistCard(stylist, isSelected),
                        );
                      },
                      childCount: _stylists.length,
                    ),
                  ),
                ),
            ],
          ),
          // 固定顶部导航栏
          _buildHeader(),
          // 固定底部操作栏
          _buildBottomBar(selectedName),
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
                  '选择理发师',
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

  Widget _buildNoPreferenceCard() {
    final isSelected = _selectedStylistId == null;

    return GestureDetector(
      onTap: () => _handleSelectStylist(null, null),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF385C)
                : const Color(0xFFD1D5DB),
            width: 2,
            style: isSelected ? BorderStyle.solid : BorderStyle.solid,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE9D5FF), Color(0xFFFCE7F3)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Text(
                  '🎲',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '不指定理发师',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '系统自动分配',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylistCard(Stylist stylist, bool isSelected) {
    final isBusy = stylist.status == StylistStatus.busy;

    return GestureDetector(
      onTap: () => _handleSelectStylist(stylist.id, stylist.status),
      child: Opacity(
        opacity: isBusy ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              GestureDetector(
                onTap: !isBusy ? () => _showStylistDetail(stylist) : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF472B6), Color(0xFFFB7185)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: stylist.avatarUrl != null && stylist.avatarUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                            stylist.avatarUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            stylist.name.isNotEmpty ? stylist.name.substring(0, 1) : '师',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称、状态徽章和选中标记
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  stylist.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(stylist.status),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
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
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 职称
                    if (stylist.title != null)
                      Text(
                        stylist.title!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // 从业年限
                    if (stylist.experienceYears != null) ...[
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.award,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '从业${stylist.experienceYears}年',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    // 擅长项目
                    if (stylist.specialties != null && stylist.specialties!.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: stylist.specialties!
                            .take(3)
                            .map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String selectedName) {
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
              if (selectedName.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已选：$selectedName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
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
                    gradient: _selectedStylistId != -1
                        ? const LinearGradient(
                            colors: [Color(0xFFFF385C), Color(0xFFE31C5F)],
                          )
                        : null,
                    color: _selectedStylistId != -1
                        ? null
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _selectedStylistId != -1
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
