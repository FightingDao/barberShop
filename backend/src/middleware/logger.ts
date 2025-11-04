import { Context, Next } from 'koa'
import dayjs from 'dayjs'

// 请求日志中间件
export const logger = async (ctx: Context, next: Next) => {
  const start = Date.now()
  const requestTime = dayjs().format('YYYY-MM-DD HH:mm:ss')

  // 请求开始日志
  console.log(`➡️  [${requestTime}] ${ctx.method} ${ctx.url}`)

  // 如果有请求体，打印（仅开发环境）
  if (process.env.NODE_ENV === 'development' && Object.keys(ctx.request.body || {}).length > 0) {
    console.log('   Request Body:', JSON.stringify(ctx.request.body, null, 2))
  }

  await next()

  // 计算响应时间
  const duration = Date.now() - start
  const responseTime = dayjs().format('YYYY-MM-DD HH:mm:ss')

  // 根据状态码选择不同的日志符号
  let statusSymbol = '✅'
  if (ctx.status >= 400 && ctx.status < 500) {
    statusSymbol = '⚠️ '
  } else if (ctx.status >= 500) {
    statusSymbol = '❌'
  }

  // 响应日志
  console.log(
    `${statusSymbol} [${responseTime}] ${ctx.method} ${ctx.url} - ${ctx.status} - ${duration}ms`
  )

  // 开发环境打印响应体（仅错误时）
  if (process.env.NODE_ENV === 'development' && ctx.status >= 400) {
    console.log('   Response Body:', JSON.stringify(ctx.body, null, 2))
  }
}

// 性能监控中间件
export const performanceMonitor = async (ctx: Context, next: Next) => {
  const start = Date.now()

  await next()

  const duration = Date.now() - start

  // 如果响应时间超过1秒，发出警告
  if (duration > 1000) {
    console.warn(
      `⚡ 慢请求警告: ${ctx.method} ${ctx.url} - ${duration}ms`
    )
  }

  // 添加响应时间到响应头
  ctx.set('X-Response-Time', `${duration}ms`)
}