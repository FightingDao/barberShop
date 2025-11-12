# Flutter 理发店预约 App - Provider 状态管理层和UI组件

## 项目概述

已完成的Flutter版本理发店预约App的状态管理层、通用UI组件、工具类和应用入口配置。

## 目录结构

```
lib/
├── providers/              # 状态管理Provider层
│   ├── auth_provider.dart           # 认证状态管理
│   ├── shop_provider.dart           # 店铺数据管理
│   ├── booking_provider.dart        # 预约流程管理
│   ├── appointment_provider.dart    # 预约历史管理
│   └── providers.dart               # 统一导出文件
│
├── widgets/               # 通用UI组件
│   ├── loading_widget.dart          # 加载指示器
│   ├── error_widget.dart            # 错误展示组件
│   ├── empty_widget.dart            # 空状态组件
│   ├── app_button.dart              # 自定义按钮（带渐变）
│   ├── shop_card.dart               # 店铺卡片
│   ├── service_card.dart            # 服务卡片
│   └── widgets.dart                 # 统一导出文件
│
├── utils/                 # 工具类
│   ├── date_utils.dart              # 日期格式化工具
│   ├── toast_utils.dart             # Toast提示工具
│   ├── validators.dart              # 表单验证工具
│   └── utils.dart                   # 统一导出文件
│
├── pages/                 # 页面（占位符）
│   ├── login_page.dart              # 登录页
│   ├── home_page.dart               # 首页（店铺列表）
│   ├── shop_detail_page.dart        # 店铺详情页
│   ├── select_service_page.dart     # 选择服务页
│   ├── select_stylist_page.dart     # 选择理发师页
│   ├── select_time_page.dart        # 选择时间页
│   ├── confirm_booking_page.dart    # 确认预约页
│   ├── booking_success_page.dart    # 预约成功页
│   ├── appointments_page.dart       # 我的预约页
│   └── profile_page.dart            # 个人中心页
│
└── main.dart              # 应用入口文件
```

## 已实现功能

### 1. Providers（状态管理）

#### AuthProvider - 认证状态管理
- 用户登录/注销
- 发送验证码
- 获取/更新用户信息
- 自动初始化本地登录状态

**主要方法:**
- `login(phone, code)` - 手机号登录
- `sendVerificationCode(phone)` - 发送验证码
- `logout()` - 登出
- `loadUser()` - 加载用户信息
- `updateProfile(data)` - 更新用户信息

#### ShopProvider - 店铺数据管理
- 获取店铺列表
- 获取店铺详情
- 获取店铺服务列表
- 获取店铺理发师列表

**主要方法:**
- `fetchShops({search})` - 获取店铺列表（支持搜索）
- `fetchShopDetail(shopId)` - 获取店铺详情
- `fetchServices(shopId)` - 获取服务列表
- `fetchStylists(shopId)` - 获取理发师列表
- `setSelectedShop(shop)` - 设置选中的店铺

#### BookingProvider - 预约流程管理
- 管理预约流程状态（店铺、服务、理发师、时间）
- 获取可用时间段
- 创建预约

**主要方法:**
- `setShop(shop)` - 设置选中的店铺
- `setService(service)` - 设置选中的服务
- `setStylist(stylist)` - 设置选中的理发师
- `setDateTime(date, time)` - 设置日期和时间
- `fetchAvailableTimeSlots()` - 获取可用时间段
- `createAppointment({notes})` - 创建预约
- `clear()` - 清空所有状态

#### AppointmentProvider - 预约历史管理
- 获取预约列表
- 取消预约
- 过滤不同状态的预约

**主要方法:**
- `fetchAppointments({status})` - 获取预约列表
- `fetchAppointmentDetail(id)` - 获取预约详情
- `cancelAppointment(id)` - 取消预约
- `refresh()` - 刷新列表

**Getters:**
- `pendingAppointments` - 待处理的预约
- `completedAppointments` - 已完成的预约
- `cancelledAppointments` - 已取消的预约

### 2. Widgets（通用UI组件）

#### LoadingWidget
加载指示器，带有可选的提示文本
```dart
LoadingWidget(message: '加载中...', size: 40.0)
```

#### ErrorWidget
错误展示组件，带有重试按钮
```dart
ErrorWidget(
  message: '加载失败',
  onRetry: () => fetchData(),
)
```

#### EmptyWidget
空状态展示组件
```dart
EmptyWidget(
  message: '暂无数据',
  icon: Icons.inbox_outlined,
)
```

#### AppButton
自定义按钮，支持渐变背景、加载状态、轮廓样式
```dart
AppButton(
  text: '立即预约',
  onPressed: () {},
  isLoading: false,
  isOutlined: false,
  icon: Icons.calendar_today,
)
```

#### ShopCard
店铺卡片组件，展示店铺信息
```dart
ShopCard(
  shop: shop,
  onTap: () => goToShopDetail(shop.id),
)
```

#### ServiceCard
服务卡片组件，展示服务信息和选中状态
```dart
ServiceCard(
  service: service,
  isSelected: selectedService?.id == service.id,
  onTap: () => selectService(service),
)
```

### 3. Utils（工具类）

#### DateUtils
日期格式化工具类
- `formatDate(date)` - 格式化为 YYYY-MM-DD
- `formatDateChinese(date)` - 格式化为 YYYY年MM月DD日
- `formatTime(time)` - 格式化为 HH:mm
- `getWeekdayChinese(date)` - 获取星期几
- `isToday(date)` - 判断是否为今天
- `getDateDisplayText(date)` - 获取显示文本（今天/明天/日期）

#### ToastUtils
Toast提示工具类
- `show(message)` - 显示普通提示
- `success(message)` - 显示成功提示
- `error(message)` - 显示错误提示
- `warning(message)` - 显示警告提示
- `info(message)` - 显示信息提示

#### Validators
表单验证工具类
- `validatePhone(value)` - 验证手机号
- `validateCode(value)` - 验证验证码
- `validateNickname(value)` - 验证昵称
- `validateRequired(value)` - 验证必填字段
- `validateEmail(value)` - 验证邮箱
- `validatePassword(value)` - 验证密码

### 4. 主应用配置（main.dart）

#### 功能特性
- **MultiProvider设置**: 配置了所有4个Provider
- **GoRouter路由**: 完整的路由配置，包含所有页面
- **认证守卫**: 未登录自动重定向到登录页
- **主题配置**: 使用AppTheme.lightTheme
- **初始化**: 启动时初始化StorageService

#### 路由列表
- `/login` - 登录页
- `/` - 首页（店铺列表）
- `/shop/:id` - 店铺详情页
- `/booking/select-service/:shopId` - 选择服务
- `/booking/select-stylist/:shopId` - 选择理发师
- `/booking/select-time/:shopId` - 选择时间
- `/booking/confirm/:shopId` - 确认预约
- `/booking/success` - 预约成功
- `/appointments` - 我的预约
- `/profile` - 个人中心

## 设计风格

所有UI组件都遵循frontend_old的设计风格：
- **主色调**: #FF4D6A（红/粉色）
- **圆角**: 8px-24px不同尺寸
- **阴影**: 多层次阴影效果
- **渐变**: 主要按钮使用渐变背景
- **卡片**: 白色背景+阴影+圆角

## 使用示例

### 在页面中使用Provider

```dart
import 'package:provider/provider.dart';
import '../providers/providers.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取Provider
    final authProvider = context.watch<AuthProvider>();
    final shopProvider = context.read<ShopProvider>();

    // 使用Provider中的数据
    if (authProvider.isLoggedIn) {
      return Text('欢迎，${authProvider.currentUser?.nickname}');
    }

    // 调用Provider方法
    ElevatedButton(
      onPressed: () => shopProvider.fetchShops(),
      child: Text('加载店铺'),
    );
  }
}
```

### 使用通用组件

```dart
import '../widgets/widgets.dart';

// 显示加载状态
if (provider.isLoading) {
  return LoadingWidget(message: '加载中...');
}

// 显示错误
if (provider.errorMessage != null) {
  return ErrorWidget(
    message: provider.errorMessage!,
    onRetry: () => provider.fetchData(),
  );
}

// 显示空状态
if (provider.data.isEmpty) {
  return EmptyWidget(message: '暂无数据');
}

// 使用按钮
AppButton(
  text: '立即预约',
  onPressed: () => bookNow(),
  isLoading: provider.isLoading,
)
```

### 使用工具类

```dart
import '../utils/utils.dart';

// 日期格式化
final dateText = DateUtils.formatDateChinese(DateTime.now());
// 输出: 2025年11月11日

// 显示Toast
ToastUtils.success('预约成功！');
ToastUtils.error('操作失败，请重试');

// 表单验证
TextFormField(
  validator: Validators.validatePhone,
  decoration: InputDecoration(labelText: '手机号'),
)
```

## 下一步工作

需要实现具体的页面UI：
1. LoginPage - 登录页面（手机号+验证码）
2. HomePage - 店铺列表页
3. ShopDetailPage - 店铺详情页
4. SelectServicePage - 选择服务页
5. SelectStylistPage - 选择理发师页
6. SelectTimePage - 选择时间页
7. ConfirmBookingPage - 确认预约页
8. BookingSuccessPage - 预约成功页
9. AppointmentsPage - 我的预约列表页
10. ProfilePage - 个人中心页

所有页面都应使用已创建的Provider和通用组件。

## 技术栈

- **Flutter SDK**: ^3.9.2
- **状态管理**: provider ^6.1.2
- **路由导航**: go_router ^14.6.2
- **网络请求**: dio ^5.7.0
- **本地存储**: shared_preferences ^2.3.5
- **日期处理**: intl ^0.20.2
- **Toast提示**: fluttertoast ^8.2.8

## 注意事项

1. 所有Provider都继承自ChangeNotifier，使用notifyListeners()通知UI更新
2. 网络请求的错误处理已在Provider中实现
3. 所有Widget组件都支持自定义样式参数
4. 路由配置包含了认证守卫，未登录用户会自动跳转到登录页
5. 主题颜色严格遵循frontend_old的设计（#FF4D6A）

## 文件说明

所有文件都已创建并可以直接使用。页面文件（lib/pages/）目前是占位符，需要后续实现具体的UI和逻辑。
