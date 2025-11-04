# 理发店预约App - 技术设计方案

## 1. 项目概述

### 1.1 项目名称
BarberShop - 理发店预约移动应用

### 1.2 技术目标
- 构建现代化的全栈移动应用
- 实现流畅的用户预约体验
- 确保代码质量和可维护性
- 支持快速迭代和扩展

## 2. 技术栈选型

### 2.1 前端技术栈
| 技术 | 版本 | 选择理由 |
|------|------|----------|
| React | 18.x | 成熟稳定，生态丰富，社区活跃 |
| TypeScript | 5.x | 提供类型安全，减少运行时错误 |
| Vite | 4.x | 快速构建工具，提升开发体验 |
| react-vant | 4.x | 专为移动端设计的UI组件库 |
| React Router v6 | 6.x | 现代化路由管理 |
| Redux Toolkit | 1.x | 简化状态管理，内置DevTools |
| Axios | 1.x | 可靠的HTTP请求库 |
| dayjs | 1.x | 轻量级日期处理库 |

### 2.2 后端技术栈
| 技术 | 版本 | 选择理由 |
|------|------|----------|
| Node.js | 18.x | JavaScript运行时，性能优异 |
| Koa2 | 2.x | 轻量级Web框架，中间件机制优秀 |
| TypeScript | 5.x | 类型安全，提升开发效率 |
| PostgreSQL | 15.x | 强大的关系型数据库，支持复杂查询 |
| Prisma | 5.x | 现代化ORM，类型安全，易于使用 |
| JWT | 9.x | 无状态认证，适合移动端 |
| bcryptjs | 2.x | 密码加密库 |
| joi | 17.x | 数据验证库 |

### 2.3 开发工具
| 工具 | 用途 |
|------|------|
| ESLint + Prettier | 代码规范和格式化 |
| Husky + lint-staged | Git hooks，提交前检查 |
| nodemon | 开发时自动重启服务 |
| concurrently | 同时运行多个命令 |

## 3. 系统架构设计

### 3.1 整体架构
```
┌─────────────────────────────────────────────────────────┐
│                    用户层                                │
├─────────────────────┬───────────────────────────────────┤
│   H5移动端          │            API客户端              │
│   (React + Vant)    │          (Axios)                  │
└─────────────────────┴───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   网关层                                │
│              (CORS + 日志 + 错误处理)                   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   应用层                                │
│  ┌─────────────┬─────────────┬─────────────┬───────────┐│
│  │  用户模块   │   店铺模块  │  预约模块   │  时间模块 ││
│  └─────────────┴─────────────┴─────────────┴───────────┘│
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   数据层                                │
│                 (PostgreSQL)                           │
│  ┌─────────────┬─────────────┬─────────────┬───────────┐│
│  │   用户表    │   店铺表    │   预约表    │  服务表   ││
│  └─────────────┴─────────────┴─────────────┴───────────┘│
└─────────────────────────────────────────────────────────┘
```

### 3.2 前端架构
```
src/
├── components/          # 通用组件
│   ├── common/         # 基础组件
│   └── business/       # 业务组件
├── pages/              # 页面组件
│   ├── shops/          # 店铺相关页面
│   ├── booking/        # 预约流程页面
│   └── profile/        # 个人中心页面
├── store/              # 状态管理
│   ├── slices/         # Redux切片
│   └── api/            # API切片
├── services/           # API服务
├── utils/              # 工具函数
├── hooks/              # 自定义Hooks
├── types/              # TypeScript类型定义
└── assets/             # 静态资源
```

### 3.3 后端架构
```
src/
├── controllers/        # 控制器层
├── services/           # 业务逻辑层
├── models/             # 数据模型
├── middleware/         # 中间件
├── routes/             # 路由定义
├── utils/              # 工具函数
├── config/             # 配置文件
├── types/              # TypeScript类型
└── prisma/             # 数据库Schema
```

## 4. 数据库设计

### 4.1 核心数据表

#### 用户表 (users)
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  phone VARCHAR(20) UNIQUE NOT NULL,
  nickname VARCHAR(50),
  avatar_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 店铺表 (shops)
```sql
CREATE TABLE shops (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  description TEXT,
  avatar_url VARCHAR(255),
  opening_time TIME NOT NULL DEFAULT '09:00:00',
  closing_time TIME NOT NULL DEFAULT '21:00:00',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 服务表 (services)
```sql
CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  shop_id INTEGER REFERENCES shops(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  duration_minutes INTEGER NOT NULL,
  icon_url VARCHAR(255),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 理发师表 (stylists)
```sql
CREATE TABLE stylists (
  id SERIAL PRIMARY KEY,
  shop_id INTEGER REFERENCES shops(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  avatar_url VARCHAR(255),
  title VARCHAR(50),
  experience_years INTEGER,
  specialties TEXT[], -- PostgreSQL数组类型
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 预约表 (appointments)
```sql
CREATE TABLE appointments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  shop_id INTEGER REFERENCES shops(id),
  service_id INTEGER REFERENCES services(id),
  stylist_id INTEGER REFERENCES stylists(id),
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  duration_minutes INTEGER NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- pending, completed, cancelled
  notes TEXT,
  confirmation_code VARCHAR(10) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 时间段可用性表 (time_slots)
```sql
CREATE TABLE time_slots (
  id SERIAL PRIMARY KEY,
  shop_id INTEGER REFERENCES shops(id),
  stylist_id INTEGER REFERENCES stylists(id),
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT true,
  appointment_id INTEGER REFERENCES appointments(id),
  UNIQUE(shop_id, stylist_id, date, start_time)
);
```

### 4.2 数据库索引
```sql
-- 提升查询性能的索引
CREATE INDEX idx_appointments_user_status ON appointments(user_id, status);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
CREATE INDEX idx_time_slots_date ON time_slots(date);
CREATE INDEX idx_services_shop_active ON services(shop_id, is_active);
CREATE INDEX idx_stylists_shop_active ON stylists(shop_id, status);
```

## 5. API接口设计

### 5.1 RESTful API规范
- 使用HTTP动词表示操作：GET(查询)、POST(创建)、PUT(更新)、DELETE(删除)
- 使用名词表示资源，URL结构清晰
- 统一的响应格式和错误处理
- 版本控制：`/api/v1/`

### 5.2 核心API接口

#### 店铺相关接口
```
GET    /api/v1/shops              # 获取店铺列表（支持位置和搜索）
GET    /api/v1/shops/:id          # 获取店铺详情
GET    /api/v1/shops/:id/services # 获取店铺服务列表
GET    /api/v1/shops/:id/stylists # 获取店铺理发师列表
```

#### 预约相关接口
```
GET    /api/v1/availability       # 获取可用时间段
POST   /api/v1/appointments       # 创建预约
GET    /api/v1/appointments       # 获取用户预约列表
GET    /api/v1/appointments/:id   # 获取预约详情
PUT    /api/v1/appointments/:id/cancel  # 取消预约
```

#### 用户认证接口
```
POST   /api/v1/auth/login         # 手机号登录/注册
POST   /api/v1/auth/verify        # 验证码验证
GET    /api/v1/auth/profile       # 获取用户信息
PUT    /api/v1/auth/profile       # 更新用户信息
```

### 5.3 响应格式标准
```typescript
// 成功响应
{
  success: true,
  data: any,
  message?: string,
  pagination?: {
    page: number,
    limit: number,
    total: number
  }
}

// 错误响应
{
  success: false,
  error: {
    code: string,
    message: string,
    details?: any
  }
}
```

## 6. 前端页面设计

### 6.1 页面路由结构
```
/                           # 首页 - 店铺列表
/shops/:id                  # 店铺详情页
/booking/select-service     # 选择服务
/booking/select-stylist     # 选择理发师
/booking/select-time        # 选择时间
/booking/confirm            # 确认预约
/booking/success            # 预约成功
/profile/appointments       # 我的预约
/profile/appointments/:id   # 预约详情
```

### 6.2 状态管理设计
使用Redux Toolkit管理状态：
```typescript
// Store结构
interface RootState {
  auth: AuthState;           // 用户认证信息
  shops: ShopsState;         // 店铺数据
  booking: BookingState;     // 预约流程数据
  appointments: AppointmentsState; // 预约记录
  ui: UIState;              // UI状态（loading、toast等）
}
```

### 6.3 预约流程数据流
```
选择店铺 → 选择服务 → 选择理发师 → 选择时间 → 确认订单 → 提交预约
    ↓         ↓         ↓         ↓         ↓         ↓
  更新     更新booking  更新booking  更新booking  检查数据   调用API
shops状态   的service   的stylist   的timeSlot  完整性     创建预约
```

## 7. 关键业务逻辑

### 7.1 时间段可用性计算
```typescript
// 时间段可用性判断逻辑
function isTimeSlotAvailable(
  date: Date,
  time: Time,
  serviceDuration: number,
  existingAppointments: Appointment[]
): boolean {
  const endTime = addMinutes(time, serviceDuration);
  const slotDate = format(date, 'yyyy-MM-dd');

  // 检查是否在营业时间内
  if (time < OPENING_TIME || endTime > CLOSING_TIME) {
    return false;
  }

  // 检查是否与现有预约冲突
  return !existingAppointments.some(appointment => {
    const appointmentEnd = addMinutes(appointment.time, appointment.duration);
    return (
      appointment.date === slotDate &&
      ((time >= appointment.time && time < appointmentEnd) ||
       (endTime > appointment.time && endTime <= appointmentEnd))
    );
  });
}
```

### 7.2 预约冲突处理
```typescript
// 乐观锁机制防止超约
async function createAppointment(data: AppointmentData) {
  return await prisma.$transaction(async (tx) => {
    // 1. 再次检查时间段可用性
    const isAvailable = await checkTimeSlotAvailability(tx, data);
    if (!isAvailable) {
      throw new Error('时间段已被预约，请选择其他时间');
    }

    // 2. 锁定时间段
    await lockTimeSlot(tx, data);

    // 3. 创建预约记录
    const appointment = await tx.appointments.create({
      data: {
        ...data,
        confirmationCode: generateConfirmationCode(),
        status: 'pending'
      }
    });

    return appointment;
  });
}
```

## 8. 安全性设计

### 8.1 认证与授权
- JWT Token认证，有效期7天
- API接口权限验证中间件
- 敏感操作需要重新验证

### 8.2 数据安全
- 密码使用bcrypt加密存储
- 手机号脱敏显示
- API参数验证和SQL注入防护
- HTTPS传输加密

### 8.3 业务安全
- 预约操作频率限制
- 取消预约时间限制（2小时前）
- 时间段预约原子性操作

## 9. 性能优化

### 9.1 前端优化
- 组件懒加载和代码分割
- 图片懒加载和压缩
- 请求缓存和离线支持
- 虚拟列表优化长列表显示

### 9.2 后端优化
- 数据库查询优化和索引设计
- Redis缓存热点数据
- API响应gzip压缩
- 分页查询避免大量数据传输

### 9.3 数据库优化
- 合理的索引设计
- 查询语句优化
- 连接池配置
- 读写分离（如需要）

## 10. 开发规范

### 10.1 代码规范
- TypeScript严格模式
- ESLint + Prettier自动格式化
- 统一的命名规范（camelCase）
- 详细的代码注释

### 10.2 Git工作流
- feature分支开发
- Pull Request代码审查
- 自动化测试和构建
- 语义化版本管理

### 10.3 测试策略
- 单元测试覆盖核心业务逻辑
- 集成测试验证API接口
- E2E测试关键用户流程
- 性能测试确保响应速度

## 11. 部署方案

### 11.1 开发环境
- 本地PostgreSQL数据库
- 前端开发服务器：http://localhost:4001
- 后端API服务器：http://localhost:4000
- 热重载和调试工具

### 11.2 生产环境
- 前端：部署到CDN或静态托管
- 后端：Docker容器化部署
- 数据库：云数据库服务
- 反向代理和负载均衡

### 11.3 CI/CD流程
- 代码提交触发自动构建
- 自动化测试和代码检查
- 通过测试后自动部署
- 监控和日志收集

## 12. 项目目录结构

```
barber-shop/
├── frontend/                 # 前端项目
│   ├── src/
│   │   ├── components/       # 组件
│   │   ├── pages/           # 页面
│   │   ├── store/           # 状态管理
│   │   ├── services/        # API服务
│   │   ├── utils/           # 工具函数
│   │   └── types/           # 类型定义
│   ├── public/              # 静态资源
│   ├── package.json
│   └── vite.config.ts
├── backend/                  # 后端项目
│   ├── src/
│   │   ├── controllers/     # 控制器
│   │   ├── services/        # 业务逻辑
│   │   ├── models/          # 数据模型
│   │   ├── middleware/      # 中间件
│   │   ├── routes/          # 路由
│   │   └── utils/           # 工具函数
│   ├── prisma/              # 数据库Schema
│   ├── package.json
│   └── tsconfig.json
├── docs/                     # 文档目录
│   ├── PRD_claude.md
│   ├── TECH_DESIGN.md
│   └── API.md
├── database/                 # 数据库脚本
│   ├── init.sql
│   └── seed.sql
├── README.md                 # 项目说明
└── start.sh                 # 启动脚本
```

这个技术设计方案为理发店预约App提供了完整的开发蓝图，涵盖了从数据库设计到前端界面的所有技术细节，确保项目能够高质量、高效率地完成开发。