import { Context } from 'koa'
import prisma from '../utils/db'
import { generateToken } from '../utils/jwt'
import { success, badRequest, notFound } from '../utils/response'
import { isValidPhone } from '../utils/helpers'

// 手机号登录/注册
export const login = async (ctx: Context) => {
  const { phone } = ctx.state.validated

  // 验证手机号格式
  if (!isValidPhone(phone)) {
    badRequest(ctx, '手机号格式不正确')
    return
  }

  // 查找或创建用户
  let user = await prisma.user.findUnique({
    where: { phone },
  })

  if (!user) {
    // 自动注册新用户
    user = await prisma.user.create({
      data: {
        phone,
        nickname: `用户${phone.substring(7)}`,
      },
    })
  }

  // 生成JWT token
  const token = generateToken({
    userId: user.id,
    phone: user.phone,
  })

  success(ctx, {
    user: {
      id: user.id,
      phone: user.phone,
      nickname: user.nickname,
      avatarUrl: user.avatarUrl,
    },
    token,
  }, '登录成功')
}

// 发送验证码（简化版，实际应该集成短信服务）
export const sendVerificationCode = async (ctx: Context) => {
  const { phone } = ctx.state.validated

  if (!isValidPhone(phone)) {
    badRequest(ctx, '手机号格式不正确')
    return
  }

  // 实际应该调用短信服务发送验证码
  // 这里简化处理，仅返回成功
  console.log(`📱 发送验证码到 ${phone}: 123456`)

  success(ctx, null, '验证码已发送')
}

// 验证验证码
export const verifyCode = async (ctx: Context) => {
  const { phone, code } = ctx.state.validated

  // 简化验证，实际应该验证真实的验证码
  // 开发环境任意验证码都通过
  if (process.env.NODE_ENV === 'development' || code === '123456') {
    success(ctx, { verified: true }, '验证成功')
  } else {
    badRequest(ctx, '验证码错误')
  }
}

// 获取用户信息
export const getProfile = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      phone: true,
      nickname: true,
      avatarUrl: true,
      createdAt: true,
      updatedAt: true,
    },
  })

  if (!user) {
    notFound(ctx, '用户不存在')
    return
  }

  success(ctx, user)
}

// 更新用户信息
export const updateProfile = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const { nickname, avatarUrl } = ctx.state.validated

  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      nickname,
      avatarUrl,
    },
    select: {
      id: true,
      phone: true,
      nickname: true,
      avatarUrl: true,
      updatedAt: true,
    },
  })

  success(ctx, user, '更新成功')
}

// 登出
export const logout = async (ctx: Context) => {
  // JWT是无状态的，登出主要由客户端处理（删除token）
  success(ctx, null, '登出成功')
}