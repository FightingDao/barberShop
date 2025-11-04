import { Context } from 'koa'

export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  error?: {
    code: string
    message: string
    details?: any
  }
  pagination?: {
    page: number
    limit: number
    total: number
  }
}

// 成功响应
export const success = <T>(ctx: Context, data?: T, message?: string, pagination?: any) => {
  const response: ApiResponse<T> = {
    success: true,
    data,
    message,
  }

  if (pagination) {
    response.pagination = pagination
  }

  ctx.status = 200
  ctx.body = response
}

// 创建成功响应（201）
export const created = <T>(ctx: Context, data?: T, message?: string) => {
  ctx.status = 201
  ctx.body = {
    success: true,
    data,
    message: message || '创建成功',
  }
}

// 错误响应
export const error = (
  ctx: Context,
  code: string,
  message: string,
  status: number = 400,
  details?: any
) => {
  ctx.status = status
  ctx.body = {
    success: false,
    error: {
      code,
      message,
      details,
    },
  }
}

// 常见错误响应
export const badRequest = (ctx: Context, message: string = '请求参数错误', details?: any) => {
  error(ctx, 'BAD_REQUEST', message, 400, details)
}

export const unauthorized = (ctx: Context, message: string = '未授权') => {
  error(ctx, 'UNAUTHORIZED', message, 401)
}

export const forbidden = (ctx: Context, message: string = '禁止访问') => {
  error(ctx, 'FORBIDDEN', message, 403)
}

export const notFound = (ctx: Context, message: string = '资源不存在') => {
  error(ctx, 'NOT_FOUND', message, 404)
}

export const conflict = (ctx: Context, message: string = '资源冲突') => {
  error(ctx, 'CONFLICT', message, 409)
}

export const serverError = (ctx: Context, message: string = '服务器内部错误', details?: any) => {
  error(ctx, 'INTERNAL_ERROR', message, 500, details)
}