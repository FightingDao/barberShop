import apiService from './api'
import { User, ApiResponse } from '@/types'

export interface LoginParams {
  phone: string
  code?: string
}

export interface LoginResponse {
  user: User
  token: string
}

export const authApi = {
  // 手机号登录/注册
  login: (params: LoginParams): Promise<ApiResponse<LoginResponse>> => {
    return apiService.post('/api/v1/auth/login', params)
  },

  // 发送验证码
  sendVerificationCode: (phone: string): Promise<ApiResponse<void>> => {
    return apiService.post('/api/v1/auth/send-code', { phone })
  },

  // 验证码验证
  verifyCode: (phone: string, code: string): Promise<ApiResponse<string>> => {
    return apiService.post('/api/v1/auth/verify', { phone, code })
  },

  // 获取用户信息
  getProfile: (): Promise<ApiResponse<User>> => {
    return apiService.get('/api/v1/auth/profile')
  },

  // 更新用户信息
  updateProfile: (data: Partial<User>): Promise<ApiResponse<User>> => {
    return apiService.put('/api/v1/auth/profile', data)
  },

  // 登出
  logout: (): Promise<ApiResponse<void>> => {
    return apiService.post('/api/v1/auth/logout')
  },
}