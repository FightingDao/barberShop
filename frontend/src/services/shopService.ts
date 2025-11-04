import apiService from './api'
import { Shop, Service, Stylist, ShopQueryParams, ApiResponse } from '@/types'

export const shopApi = {
  // 获取店铺列表
  getShops: (params?: ShopQueryParams): Promise<ApiResponse<Shop[]>> => {
    return apiService.get('/api/v1/shops', params)
  },

  // 获取店铺详情
  getShopDetail: (id: number): Promise<ApiResponse<Shop>> => {
    return apiService.get(`/api/v1/shops/${id}`)
  },

  // 获取店铺服务列表
  getShopServices: (shopId: number): Promise<ApiResponse<Service[]>> => {
    return apiService.get(`/api/v1/shops/${shopId}/services`)
  },

  // 获取店铺理发师列表
  getShopStylists: (shopId: number): Promise<ApiResponse<Stylist[]>> => {
    return apiService.get(`/api/v1/shops/${shopId}/stylists`)
  },
}