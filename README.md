# 理发店预约系统

一个基于 React + Node.js + PostgreSQL 的完整理发店预约管理系统。

## 🌟 功能特性

### 用户端
- 📍 店铺浏览与搜索
- 💇 服务项目选择
- 👨‍🦲 理发师选择
- 📅 时间段预约
- 📱 我的预约管理
- ✅ 预约取消

### 技术栈

#### 前端
- React 18 + TypeScript
- Vite 构建工具
- Redux Toolkit 状态管理
- React Router v7 路由
- React Vant UI 组件库
- Axios HTTP 客户端

#### 后端
- Node.js + Koa2
- TypeScript
- Prisma ORM
- JWT 认证
- PostgreSQL 数据库

## 📦 项目结构

\`\`\`
barberShop/
├── frontend/          # React 前端应用
│   ├── src/
│   │   ├── pages/     # 页面组件
│   │   ├── components/# 公共组件
│   │   ├── store/     # Redux 状态管理
│   │   ├── services/  # API 服务
│   │   └── types/     # TypeScript 类型
│   └── package.json
├── backend/           # Node.js 后端服务
│   ├── src/
│   │   ├── controllers/  # 控制器
│   │   ├── routes/       # 路由
│   │   ├── middleware/   # 中间件
│   │   ├── utils/        # 工具函数
│   │   └── index.ts      # 入口文件
│   ├── prisma/
│   │   ├── schema.prisma # 数据库模型
│   │   └── seed.ts       # 种子数据
│   └── package.json
├── DEPLOY.md          # 部署文档
└── README.md          # 本文档
\`\`\`

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0.0
- PostgreSQL >= 15
- npm 或 yarn

### 本地开发

#### 1. 克隆项目
\`\`\`bash
git clone https://github.com/YOUR_USERNAME/barberShop.git
cd barberShop
\`\`\`

#### 2. 安装数据库
\`\`\`bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# 创建数据库用户
createuser -s barber_user
psql -c "ALTER USER barber_user WITH PASSWORD 'barber_password';"

# 创建数据库
createdb barber_shop -O barber_user
\`\`\`

#### 3. 配置后端
\`\`\`bash
cd backend

# 安装依赖
npm install

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件

# 运行数据库迁移
npx prisma migrate dev

# 生成测试数据
npm run prisma:seed

# 启动开发服务器
npm run dev
\`\`\`

后端服务将运行在 http://localhost:4000

#### 4. 配置前端
\`\`\`bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
\`\`\`

前端应用将运行在 http://localhost:4001

### 访问应用

打开浏览器访问 http://localhost:4001

测试账号：
- 手机号: \`13800138000\`
- 验证码: 任意（开发环境）

## 📚 API 文档

### 认证相关
- \`POST /api/v1/auth/login\` - 手机号登录
- \`POST /api/v1/auth/send-code\` - 发送验证码
- \`GET /api/v1/auth/profile\` - 获取用户信息

### 店铺相关
- \`GET /api/v1/shops\` - 获取店铺列表
- \`GET /api/v1/shops/:id\` - 获取店铺详情
- \`GET /api/v1/shops/:id/services\` - 获取店铺服务
- \`GET /api/v1/shops/:id/stylists\` - 获取店铺理发师

### 预约相关
- \`GET /api/v1/availability\` - 获取可用时间段
- \`POST /api/v1/appointments\` - 创建预约
- \`GET /api/v1/appointments\` - 获取用户预约列表
- \`GET /api/v1/appointments/:id\` - 获取预约详情
- \`PUT /api/v1/appointments/:id/cancel\` - 取消预约

## 🔧 开发命令

### 后端
\`\`\`bash
npm run dev           # 启动开发服务器
npm run build         # 构建生产版本
npm start            # 启动生产服务器
npm run prisma:generate  # 生成 Prisma Client
npm run prisma:migrate   # 运行数据库迁移
npm run prisma:seed      # 生成测试数据
npm run prisma:studio    # 打开 Prisma Studio
\`\`\`

### 前端
\`\`\`bash
npm run dev          # 启动开发服务器
npm run build        # 构建生产版本
npm run preview      # 预览生产构建
npm run lint         # 代码检查
\`\`\`

## 📝 环境变量

### 后端 (.env)
\`\`\`env
NODE_ENV=development
PORT=4000
DATABASE_URL=postgresql://barber_user:barber_password@localhost:5432/barber_shop
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:4001
\`\`\`

### 前端 (.env)
\`\`\`env
VITE_API_BASE_URL=http://localhost:4000
\`\`\`

## 🚢 生产部署

详细部署文档请查看 [DEPLOY.md](./DEPLOY.md)

支持平台：
- ✅ Render
- ✅ Vercel (前端)
- ✅ Railway
- ✅ Heroku

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题，请通过 Issue 联系。
