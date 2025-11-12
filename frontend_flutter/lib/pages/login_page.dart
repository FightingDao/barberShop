import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/widgets.dart';
import '../utils/utils.dart';

/// 登录页面
/// 支持手机号 + 密码登录
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 预填测试手机号和密码（开发环境）
    _phoneController.text = '13800138000';
    _passwordController.text = 'Barber123';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 登录
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        ToastUtils.show('登录成功');
        context.go('/');
      } else {
        ToastUtils.show(authProvider.errorMessage ?? '登录失败');
      }
    } catch (e) {
      ToastUtils.show('网络错误，请重试');
      debugPrint('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo区域
              _buildLogo(),
              const SizedBox(height: AppTheme.spacingXXL),
              // 标题
              _buildTitle(),
              const SizedBox(height: AppTheme.spacingXXL),
              // 表单
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 手机号输入框
                    AppTextField(
                      controller: _phoneController,
                      label: '手机号',
                      hint: '请输入手机号',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入手机号';
                        }
                        if (value.length != 11) {
                          return '请输入正确的手机号';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingLG),
                    // 密码输入框
                    AppTextField(
                      controller: _passwordController,
                      label: '密码',
                      hint: '请输入密码',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      onSuffixTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        if (value.length < 6) {
                          return '密码至少6位';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),
              // 登录按钮
              AppButton(
                text: '登录',
                onPressed: authProvider.isLoading ? null : _login,
                isLoading: authProvider.isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: AppTheme.spacingLG),
              // 错误提示
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: AppTheme.fontSizeSM,
                  ),
                ),
              const SizedBox(height: 100),
              // 底部文字
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Logo区域
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.content_cut,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        const Text(
          '理发店预约',
          style: TextStyle(
            fontSize: AppTheme.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: AppTheme.spacingSM),
        Text(
          '使用手机号和密码登录',
          style: TextStyle(
            fontSize: AppTheme.fontSizeSM,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建底部
  Widget _buildFooter() {
    return const Text(
      '登录即表示同意服务条款和隐私政策',
      style: TextStyle(
        fontSize: AppTheme.fontSizeXS,
        color: AppTheme.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
