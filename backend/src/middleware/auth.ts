import { Context, Next } from 'koa'
import { verifyToken, getTokenFromHeader, JwtPayload } from '../utils/jwt'
import { unauthorized } from '../utils/response'
import prisma from '../utils/db'

// 扩展Koa的Context类型
declare module 'koa' {
  interface Context {
    state: {
      user?: JwtPayload & { id: number }
      validated?: any
    }
  }
}

// JWT认证中间件
export const authenticate = async (ctx: Context, next: Next) => {
  try {
    // 从请求头获取token
    const token = getTokenFromHeader(ctx.headers.authorization)

    if (!token) {
      unauthorized(ctx, '请先登录')
      return
    }

    // 验证token
    const payload = verifyToken(token)

    // 验证用户是否存在
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
    })

    if (!user) {
      unauthorized(ctx, '用户不存在')
      return
    }

    // 将用户信息附加到ctx.state
    ctx.state.user = {
      ...payload,
      id: user.id,
    }

    await next()
  } catch (error) {
    unauthorized(ctx, '认证失败')
  }
}

// 可选认证中间件（不强制要求登录）
export const optionalAuth = async (ctx: Context, next: Next) => {
  try {
    const token = getTokenFromHeader(ctx.headers.authorization)

    if (token) {
      const payload = verifyToken(token)
      const user = await prisma.user.findUnique({
        where: { id: payload.userId },
      })

      if (user) {
        ctx.state.user = {
          ...payload,
          id: user.id,
        }
      }
    }

    await next()
  } catch (error) {
    // 可选认证失败不阻断请求
    await next()
  }
}