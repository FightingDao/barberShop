import { Context, Next } from 'koa'
import { serverError } from '../utils/response'

// 全局错误处理中间件
export const errorHandler = async (ctx: Context, next: Next) => {
  try {
    await next()
  } catch (err: any) {
    // 记录错误日志
    console.error('❌ 请求错误:', {
      method: ctx.method,
      url: ctx.url,
      error: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    })

    // 处理不同类型的错误
    if (err.status === 401) {
      ctx.status = 401
      ctx.body = {
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: err.message || '未授权访问',
        },
      }
    } else if (err.status === 403) {
      ctx.status = 403
      ctx.body = {
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: err.message || '禁止访问',
        },
      }
    } else if (err.status === 404) {
      ctx.status = 404
      ctx.body = {
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: err.message || '资源不存在',
        },
      }
    } else {
      // 其他错误统一返回500
      serverError(
        ctx,
        process.env.NODE_ENV === 'development' ? err.message : '服务器内部错误',
        process.env.NODE_ENV === 'development' ? err.stack : undefined
      )
    }

    // 触发Koa的错误事件
    ctx.app.emit('error', err, ctx)
  }
}

// 404处理中间件
export const notFoundHandler = async (ctx: Context) => {
  ctx.status = 404
  ctx.body = {
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `路径 ${ctx.method} ${ctx.path} 不存在`,
    },
  }
}