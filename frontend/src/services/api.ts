import axios, { AxiosInstance, AxiosResponse } from 'axios'
import { ApiResponse } from '@/types'

// API 基础配置
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000'

// 将snake_case转换为camelCase
function toCamel(str: string): string {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
}

// 递归转换对象键名
function convertKeysToCamel(obj: any): any {
  if (obj === null || obj === undefined) {
    return obj
  }
  if (Array.isArray(obj)) {
    return obj.map(v => convertKeysToCamel(v))
  } else if (typeof obj === 'object' && obj.constructor === Object) {
    return Object.keys(obj).reduce((result, key) => {
      const camelKey = toCamel(key)
      result[camelKey] = convertKeysToCamel(obj[key])
      return result
    }, {} as any)
  }
  return obj
}

// 将camelCase转换为snake_case
function toSnake(str: string): string {
  return str.replace(/([A-Z])/g, '_$1').toLowerCase()
}

// 递归转换对象键名
function convertKeysToSnake(obj: any): any {
  if (obj === null || obj === undefined) {
    return obj
  }
  if (Array.isArray(obj)) {
    return obj.map(v => convertKeysToSnake(v))
  } else if (typeof obj === 'object' && obj.constructor === Object) {
    return Object.keys(obj).reduce((result, key) => {
      const snakeKey = toSnake(key)
      result[snakeKey] = convertKeysToSnake(obj[key])
      return result
    }, {} as any)
  }
  return obj
}

class ApiService {
  private instance: AxiosInstance

  constructor() {
    this.instance = axios.create({
      baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000',
      timeout: Number(import.meta.env.VITE_API_TIMEOUT) || 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    })

    // 请求拦截器
    this.instance.interceptors.request.use(
      (config) => {
        // 添加认证token
        const token = localStorage.getItem('auth_token')
        if (token) {
          config.headers.Authorization = `Bearer ${token}`
        }

        // 将请求数据的键名转换为snake_case
        if (config.data) {
          config.data = convertKeysToSnake(config.data)
        }
        if (config.params) {
          config.params = convertKeysToSnake(config.params)
        }

        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // 响应拦截器
    this.instance.interceptors.response.use(
      (response: AxiosResponse<ApiResponse>) => {
        // 将响应数据的键名转换为camelCase
        if (response.data) {
          response.data = convertKeysToCamel(response.data)
        }
        return response
      },
      (error) => {
        // 统一错误处理
        if (error.response?.status === 401) {
          // 清除token，跳转到登录页
          localStorage.removeItem('auth_token')
          window.location.href = '/login'
        }
        return Promise.reject(error)
      }
    )
  }

  // GET请求
  async get<T>(url: string, params?: any): Promise<ApiResponse<T>> {
    const response = await this.instance.get(url, { params })
    return response.data
  }

  // POST请求
  async post<T>(url: string, data?: any): Promise<ApiResponse<T>> {
    const response = await this.instance.post(url, data)
    return response.data
  }

  // PUT请求
  async put<T>(url: string, data?: any): Promise<ApiResponse<T>> {
    const response = await this.instance.put(url, data)
    return response.data
  }

  // DELETE请求
  async delete<T>(url: string): Promise<ApiResponse<T>> {
    const response = await this.instance.delete(url)
    return response.data
  }
}

export const apiService = new ApiService()
export default apiService