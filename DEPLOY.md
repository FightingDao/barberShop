# 理发店预约系统 - Render 部署教程

本教程将指导您将理发店预约系统（前端 + 后端 + 数据库）完整部署到 Render 平台。

## 📋 目录

1. [准备工作](#准备工作)
2. [方式一：使用 render.yaml 部署（推荐）](#方式一使用-renderyaml-部署推荐)
3. [方式二：通过 Dashboard 手动部署](#方式二通过-dashboard-手动部署)
4. [运行数据库迁移](#运行数据库迁移)
5. [验证部署](#验证部署)
6. [常见问题](#常见问题)

---

## 准备工作

### 1. 注册 Render 账号
- 访问 [https://render.com](https://render.com)
- 使用 GitHub 账号注册（推荐）或邮箱注册

### 2. 准备代码仓库
```bash
# 初始化 Git 仓库（如果还没有）
cd /Users/zhangdi/work/barberShop
git init
git add .
git commit -m "Initial commit"

# 创建 GitHub 仓库并推送
# 在 GitHub 上创建新仓库，然后：
git remote add origin https://github.com/YOUR_USERNAME/barberShop.git
git branch -M main
git push -u origin main
```

### 3. 项目结构检查
确保项目结构如下：
```
barberShop/
├── frontend/          # React 前端
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
├── backend/           # Node.js 后端
│   ├── package.json
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   └── src/
└── DEPLOY.md         # 本文档
```

---

## 方式一：使用 render.yaml 部署（推荐）

### ✨ 优势

使用 `render.yaml` 可以获得：
- ✅ **PR Previews**: 每个 Pull Request 自动创建预览环境
- ✅ **Auto-Deploy**: 代码推送后自动部署
- ✅ **版本控制**: 所有配置都在代码仓库中
- ✅ **可重复性**: 轻松在不同环境重建相同配置

### 步骤 1: 准备 render.yaml

项目根目录已包含 `render.yaml` 文件，内容包括：
- PostgreSQL 数据库配置
- 后端 Web Service 配置
- 前端 Static Site 配置

### 步骤 2: 连接 GitHub 仓库

1. 登录 Render Dashboard
2. 点击右上角头像 → **Account Settings**
3. 在左侧菜单点击 **GitHub**
4. 点击 **Connect Account** 连接您的 GitHub 账号
5. 授权 Render 访问您的仓库

### 步骤 3: 创建 Blueprint

1. 在 Render Dashboard 点击 **New +** → **Blueprint**
2. 选择您的 GitHub 仓库 `barberShop`
3. Render 会自动检测 `render.yaml` 文件
4. 点击 **Apply**

### 步骤 4: 配置敏感环境变量

`render.yaml` 中的 `JWT_SECRET` 设置为自动生成，但您也可以自定义：

1. 在创建的服务中找到 **barber-shop-backend**
2. 进入 **Environment** 标签
3. 修改 `JWT_SECRET` 值（可选）
4. 点击 **Save Changes**

### 步骤 5: 等待部署完成

Render 将自动：
1. 创建 PostgreSQL 数据库
2. 部署后端服务
3. 部署前端应用
4. 设置环境变量
5. 运行构建脚本

部署过程大约需要 5-10 分钟。

### 步骤 6: 更新 CORS 配置

部署完成后：
1. 复制前端 URL（如 `https://barber-shop-frontend.onrender.com`）
2. 更新 `render.yaml` 中的 `CORS_ORIGIN` 值
3. 提交并推送到 GitHub
4. Render 将自动重新部署

### 🎯 自动部署流程

之后每次推送代码到 main 分支：
1. GitHub 自动触发 webhook
2. Render 自动拉取最新代码
3. 运行构建脚本
4. 自动部署到生产环境

### 🔍 PR Previews

创建 Pull Request 时：
1. Render 自动创建预览环境
2. 在 PR 中查看预览 URL
3. 测试通过后合并到 main
4. 预览环境自动删除

---

## 方式二：通过 Dashboard 手动部署

如果您不想使用 render.yaml，也可以通过 Dashboard 手动配置。

### 部署 PostgreSQL 数据库

### 步骤 1: 创建数据库实例

1. 登录 Render Dashboard
2. 点击 **"New +"** → 选择 **"PostgreSQL"**
3. 配置数据库：
   - **Name**: `barber-shop-db`
   - **Database**: `barber_shop`
   - **User**: `barber_user` (自动生成)
   - **Region**: 选择最近的区域（如 Singapore）
   - **PostgreSQL Version**: 15
   - **Plan**: Free（开发测试）或 Starter（生产环境）

4. 点击 **"Create Database"**

### 步骤 2: 获取数据库连接信息

创建完成后，在数据库详情页面找到：
- **Internal Database URL**: 用于后端连接
- **External Database URL**: 用于本地连接

复制 **Internal Database URL**，格式如下：
```
postgresql://barber_user:xxxxxxxxxxxx@dpg-xxxxx-a.singapore-postgres.render.com/barber_shop
```

---

## 部署后端服务

### 步骤 1: 创建后端 Web Service

1. 在 Render Dashboard 点击 **"New +"** → 选择 **"Web Service"**
2. 连接您的 GitHub 仓库
3. 配置服务：
   - **Name**: `barber-shop-backend`
   - **Region**: 与数据库相同区域
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npx prisma generate`
   - **Start Command**: `npm start`
   - **Plan**: Free 或 Starter

### 步骤 2: 配置环境变量

在 **Environment** 部分添加以下环境变量：

| Key | Value | 说明 |
|-----|-------|------|
| `NODE_ENV` | `production` | 运行环境 |
| `PORT` | `4000` | 端口号（Render 会自动覆盖） |
| `DATABASE_URL` | `[数据库 Internal URL]` | 从数据库页面复制 |
| `JWT_SECRET` | `your-super-secret-jwt-key-change-this-in-production-2024` | JWT 密钥（请更改） |
| `JWT_EXPIRES_IN` | `7d` | Token 过期时间 |
| `CORS_ORIGIN` | `https://your-frontend-url.onrender.com` | 前端 URL（稍后更新） |

### 步骤 3: 添加 package.json 脚本

确保 `backend/package.json` 包含以下脚本：

```json
{
  "scripts": {
    "start": "node dist/index.js",
    "build": "tsc",
    "dev": "nodemon src/index.ts",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate deploy",
    "prisma:seed": "ts-node prisma/seed.ts"
  }
}
```

### 步骤 4: 创建 Build 脚本

在 `backend` 目录创建 `render-build.sh`：

```bash
#!/usr/bin/env bash
# exit on error
set -o errexit

npm install
npx prisma generate
npx prisma migrate deploy
npm run build
npx ts-node prisma/seed.ts
```

赋予执行权限：
```bash
chmod +x backend/render-build.sh
```

更新 Render 配置：
- **Build Command**: `./render-build.sh`

### 步骤 5: 部署后端

点击 **"Create Web Service"**，Render 将自动：
1. 克隆代码
2. 安装依赖
3. 运行数据库迁移
4. 生成 Prisma Client
5. 构建 TypeScript
6. 启动服务

---

## 部署前端应用

### 步骤 1: 创建前端 Static Site

1. 在 Render Dashboard 点击 **"New +"** → 选择 **"Static Site"**
2. 连接您的 GitHub 仓库
3. 配置服务：
   - **Name**: `barber-shop-frontend`
   - **Branch**: `main`
   - **Root Directory**: `frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`

### 步骤 2: 配置环境变量

在 **Environment** 部分添加：

| Key | Value |
|-----|-------|
| `VITE_API_BASE_URL` | `https://barber-shop-backend.onrender.com` |

### 步骤 3: 更新前端配置

修改 `frontend/src/services/api.ts`：

```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000'
```

### 步骤 4: 添加重定向规则

在 `frontend/public` 创建 `_redirects` 文件：

```
/*    /index.html   200
```

这确保 React Router 在刷新时正常工作。

### 步骤 5: 部署前端

点击 **"Create Static Site"**，Render 将：
1. 安装依赖
2. 运行 Vite 构建
3. 发布到 CDN

---

## 配置环境变量

### 更新后端 CORS 配置

1. 前端部署完成后，复制前端 URL（如 `https://barber-shop-frontend.onrender.com`）
2. 返回后端服务的 Environment 设置
3. 更新 `CORS_ORIGIN` 为前端实际 URL
4. 保存并重新部署

### 环境变量完整清单

**后端环境变量:**
```env
NODE_ENV=production
PORT=4000
DATABASE_URL=postgresql://barber_user:xxxx@dpg-xxxx.render.com/barber_shop
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_EXPIRES_IN=7d
CORS_ORIGIN=https://barber-shop-frontend.onrender.com
```

**前端环境变量:**
```env
VITE_API_BASE_URL=https://barber-shop-backend.onrender.com
```

---

## 运行数据库迁移

### 方式 1: 通过 Render Shell

1. 进入后端服务页面
2. 点击 **"Shell"** 标签
3. 运行命令：
```bash
npx prisma migrate deploy
npx ts-node prisma/seed.ts
```

### 方式 2: 本地连接运行

```bash
# 设置数据库 URL（使用 External URL）
export DATABASE_URL="postgresql://barber_user:xxxx@dpg-xxxx.render.com/barber_shop"

cd backend
npx prisma migrate deploy
npx ts-node prisma/seed.ts
```

---

## 验证部署

### 1. 检查数据库
```bash
# 使用 External URL 连接
psql postgresql://barber_user:xxxx@dpg-xxxx.render.com/barber_shop

# 验证表
\dt

# 检查数据
SELECT COUNT(*) FROM shops;
```

### 2. 测试后端 API
```bash
# 健康检查
curl https://barber-shop-backend.onrender.com/api/v1/health

# 获取店铺列表
curl https://barber-shop-backend.onrender.com/api/v1/shops
```

### 3. 测试前端
访问: `https://barber-shop-frontend.onrender.com`

检查：
- ✅ 页面正常加载
- ✅ 能看到店铺列表
- ✅ 能查看店铺详情
- ✅ 预约流程正常

---

## 常见问题

### Q1: 数据库连接失败
**问题**: `Error: P1001: Can't reach database server`

**解决方案**:
1. 确认使用 **Internal Database URL**（不是 External）
2. 检查数据库状态是否为 "Available"
3. 确认后端服务和数据库在同一区域

### Q2: CORS 错误
**问题**: `Access to XMLHttpRequest has been blocked by CORS policy`

**解决方案**:
1. 检查后端 `CORS_ORIGIN` 环境变量
2. 确保 URL 完全匹配（包括 https://）
3. 不要在 URL 末尾加斜杠

### Q3: 构建失败
**问题**: `Build failed with exit code 1`

**解决方案**:
1. 检查 Build Command 是否正确
2. 查看构建日志找到具体错误
3. 确保 package.json 中所有依赖都已声明

### Q4: 前端路由 404
**问题**: 刷新页面出现 404

**解决方案**:
确保创建了 `frontend/public/_redirects` 文件：
```
/*    /index.html   200
```

### Q5: 数据库迁移失败
**问题**: Prisma migrate 报错

**解决方案**:
1. 使用 `prisma migrate deploy` 而不是 `prisma migrate dev`
2. 确保 DATABASE_URL 正确
3. 检查 schema.prisma 语法

### Q6: 环境变量不生效
**问题**: 修改环境变量后没有变化

**解决方案**:
1. 保存环境变量后需要手动重新部署
2. 点击 "Manual Deploy" → "Deploy latest commit"

### Q7: Free Plan 限制
**问题**: 服务休眠或性能问题

**Render Free Plan 限制**:
- 15 分钟不活动后服务休眠
- 重新唤醒需要 30-60 秒
- 每月 750 小时免费时长
- 数据库存储限制 1GB

**解决方案**:
- 升级到 Starter Plan ($7/月)
- 使用 UptimeRobot 定期 ping 保持活跃

---

## 🎯 部署检查清单

部署前确认：
- [ ] 代码已推送到 GitHub
- [ ] 所有环境变量已配置
- [ ] Build 命令正确
- [ ] _redirects 文件已创建
- [ ] CORS 配置正确

部署后验证：
- [ ] 数据库连接正常
- [ ] 后端 API 响应正常
- [ ] 前端页面加载成功
- [ ] 登录功能正常
- [ ] 预约流程完整
- [ ] 图片资源加载正常

---

## 📚 相关链接

- [Render 官方文档](https://render.com/docs)
- [Prisma 部署指南](https://www.prisma.io/docs/guides/deployment)
- [Vite 部署文档](https://vitejs.dev/guide/static-deploy.html)

---

## 🆘 获取帮助

如遇到问题：
1. 查看 Render 服务日志
2. 检查 GitHub Issues
3. 访问 Render 社区论坛
4. 联系技术支持

---

## 📝 更新日志

### 2024-01-04
- 初始版本
- 添加完整部署流程
- 包含常见问题解决方案

---

**祝部署顺利！🚀**
