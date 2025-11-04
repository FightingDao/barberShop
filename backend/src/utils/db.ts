import { PrismaClient } from '@prisma/client'

// 创建Prisma客户端实例
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
})

// 处理连接错误
prisma.$connect()
  .then(() => {
    console.log('✅ 数据库连接成功')
  })
  .catch((error) => {
    console.error('❌ 数据库连接失败:', error)
    process.exit(1)
  })

// 优雅关闭
process.on('beforeExit', async () => {
  await prisma.$disconnect()
})

export default prisma