import Koa from 'koa'
import bodyParser from 'koa-bodyparser'
import cors from '@koa/cors'
import config from './config'
import router from './routes'
import { errorHandler, notFoundHandler } from './middleware/errorHandler'
import { logger, performanceMonitor } from './middleware/logger'
import './utils/db' // 初始化数据库连接

// 创建Koa应用
const app = new Koa()

// ============ 中间件配置 ============

// 错误处理（必须在最前面）
app.use(errorHandler)

// 性能监控
app.use(performanceMonitor)

// 日志
app.use(logger)

// CORS配置
app.use(
  cors({
    origin: config.cors.origin,
    credentials: true,
  })
)

// Body解析
app.use(
  bodyParser({
    enableTypes: ['json', 'form'],
    jsonLimit: '10mb',
    formLimit: '10mb',
  })
)

// ============ 路由配置 ============
app.use(router.routes())
app.use(router.allowedMethods())

// 404处理（必须在路由之后）
app.use(notFoundHandler)

// ============ 错误事件监听 ============
app.on('error', (err, ctx) => {
  if (config.nodeEnv === 'development') {
    console.error('服务器错误:', err)
  }
})

// ============ 启动服务器 ============
const PORT = config.port

app.listen(PORT, () => {
  console.log('========================================')
  console.log(`🚀 ${config.app.name} v${config.app.version}`)
  console.log(`📡 服务器运行在: http://localhost:${PORT}`)
  console.log(`🌍 环境: ${config.nodeEnv}`)
  console.log(`📝 API文档: http://localhost:${PORT}/api/v1/health`)
  console.log('========================================')
})

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('📴 收到SIGTERM信号，正在关闭服务器...')
  process.exit(0)
})

process.on('SIGINT', () => {
  console.log('📴 收到SIGINT信号，正在关闭服务器...')
  process.exit(0)
})

export default app