import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'config/app_theme.dart';
import 'services/services.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/appointment_provider.dart';

// Pages - will be created later, for now using placeholder pages
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/shop_detail_page.dart';
import 'pages/select_service_page.dart';
import 'pages/select_stylist_page.dart';
import 'pages/select_time_page.dart';
import 'pages/confirm_booking_page.dart';
import 'pages/booking_success_page.dart';
import 'pages/appointments_page.dart';
import 'pages/profile_page.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 配置URL策略为path模式（去掉#号）
  usePathUrlStrategy();

  // 初始化本地存储
  await StorageService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 认证Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 店铺Provider
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        // 预约Provider
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        // 预约历史Provider
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: '理发店预约',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  /// 创建路由配置
  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isLoggedIn ? '/' : '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoginPage = state.matchedLocation == '/login';

        // 如果未登录且不在登录页，重定向到登录页
        if (!isLoggedIn && !isLoginPage) {
          return '/login';
        }

        // 如果已登录且在登录页，重定向到首页
        if (isLoggedIn && isLoginPage) {
          return '/';
        }

        return null;
      },
      routes: [
        // 登录页
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        // 首页（店铺列表）
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        // 店铺详情页
        GoRoute(
          path: '/shop/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ShopDetailPage(shopId: int.parse(id));
          },
        ),
        // 选择服务页
        GoRoute(
          path: '/booking/select-service/:shopId',
          builder: (context, state) {
            final shopId = state.pathParameters['shopId']!;
            return SelectServicePage(shopId: int.parse(shopId));
          },
        ),
        // 选择理发师页
        GoRoute(
          path: '/booking/select-stylist/:shopId',
          builder: (context, state) {
            final shopId = state.pathParameters['shopId']!;
            return SelectStylistPage(shopId: int.parse(shopId));
          },
        ),
        // 选择时间页
        GoRoute(
          path: '/booking/select-time/:shopId',
          builder: (context, state) {
            final shopId = state.pathParameters['shopId']!;
            return SelectTimePage(shopId: int.parse(shopId));
          },
        ),
        // 确认预约页
        GoRoute(
          path: '/booking/confirm/:shopId',
          builder: (context, state) {
            final shopId = state.pathParameters['shopId']!;
            return ConfirmBookingPage(shopId: int.parse(shopId));
          },
        ),
        // 预约成功页
        GoRoute(
          path: '/booking/success',
          builder: (context, state) => const BookingSuccessPage(),
        ),
        // 我的预约页
        GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsPage(),
        ),
        // 个人中心页
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }
}
