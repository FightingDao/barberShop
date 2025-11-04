#!/usr/bin/env bash
# exit on error
set -o errexit

echo "📦 安装依赖..."
npm install

echo "🔧 生成 Prisma Client..."
npx prisma generate

echo "🗄️  运行数据库迁移..."
npx prisma migrate deploy

echo "🏗️  构建 TypeScript..."
npm run build

echo "🌱 运行种子数据..."
npx ts-node prisma/seed.ts

echo "✅ 构建完成!"
