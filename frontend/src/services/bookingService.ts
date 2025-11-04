import apiService from './api'
import {
  TimeSlot,
  Appointment,
  AvailabilityParams,
  CreateAppointmentParams,
  AppointmentQueryParams,
  ApiResponse,
} from '@/types'

export const bookingApi = {
  // 获取可用时间段
  getAvailability: (params: AvailabilityParams): Promise<ApiResponse<TimeSlot[]>> => {
    return apiService.get('/api/v1/availability', params)
  },

  // 创建预约
  createAppointment: (data: CreateAppointmentParams): Promise<ApiResponse<Appointment>> => {
    return apiService.post('/api/v1/appointments', data)
  },

  // 获取用户预约列表
  getAppointments: (params?: AppointmentQueryParams): Promise<ApiResponse<Appointment[]>> => {
    return apiService.get('/api/v1/appointments', params)
  },

  // 获取预约详情
  getAppointmentDetail: (id: number): Promise<ApiResponse<Appointment>> => {
    return apiService.get(`/api/v1/appointments/${id}`)
  },

  // 取消预约
  cancelAppointment: (id: number): Promise<ApiResponse<void>> => {
    return apiService.put(`/api/v1/appointments/${id}/cancel`)
  },
}