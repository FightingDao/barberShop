import jwt from 'jsonwebtoken'
import config from '../config'

export interface JwtPayload {
  userId: number
  phone: string
}

// 生成JWT token
export const generateToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
  } as any)
}

// 验证JWT token
export const verifyToken = (token: string): JwtPayload => {
  try {
    return jwt.verify(token, config.jwt.secret) as JwtPayload
  } catch (error) {
    throw new Error('Invalid token')
  }
}

// 从请求头获取token
export const getTokenFromHeader = (authorization?: string): string | null => {
  if (!authorization) {
    return null
  }

  const parts = authorization.split(' ')
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return null
  }

  return parts[1]
}