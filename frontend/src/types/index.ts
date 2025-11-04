// 用户相关类型
export interface User {
  id: number
  phone: string
  nickname?: string
  avatarUrl?: string
  createdAt: string
  updatedAt: string
}

// 店铺相关类型
export interface Shop {
  id: number
  name: string
  address: string
  phone?: string
  description?: string
  avatarUrl?: string
  openingTime: string
  closingTime: string
  latitude?: number
  longitude?: number
  status: 'active' | 'inactive'
  distance?: number // 计算得出的距离
  createdAt: string
  updatedAt: string
}

// 服务相关类型
export interface Service {
  id: number
  shopId: number
  name: string
  description?: string
  price: number
  durationMinutes: number // 分钟数
  iconUrl?: string
  sortOrder: number
  isActive: boolean
  createdAt: string
}

// 理发师相关类型
export interface Stylist {
  id: number
  shopId: number
  name: string
  avatarUrl?: string
  title?: string
  level?: string // 职称/等级
  experience?: number // 从业年限
  specialty?: string // 擅长项目
  status: 'active' | 'inactive' | 'busy'
  createdAt: string
}

// 预约相关类型
export interface Appointment {
  id: number
  userId: number
  shopId: number
  serviceId: number
  stylistId?: number
  appointmentDate: string
  appointmentTime: string
  durationMinutes: number
  status: 'pending' | 'completed' | 'cancelled'
  notes?: string
  confirmationCode: string
  createdAt: string
  updatedAt: string

  // 关联数据
  shop?: Shop
  service?: Service
  stylist?: Stylist
}

// 时间段相关类型
export interface TimeSlot {
  id: number
  shopId: number
  stylistId?: number
  date: string
  startTime: string
  endTime: string
  isAvailable: boolean
  appointmentId?: number
}

// 预约流程数据类型
export interface BookingFlowData {
  shop: Shop | null
  service: Service | null
  stylist: Stylist | null
  date: string | null
  timeSlot: TimeSlot | null
  notes?: string
}

// API响应类型
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

// 分页参数类型
export interface PaginationParams {
  page?: number
  limit?: number
}

// 店铺查询参数类型
export interface ShopQueryParams extends PaginationParams {
  search?: string
  latitude?: number
  longitude?: number
  radius?: number
}

// 预约查询参数类型
export interface AppointmentQueryParams extends PaginationParams {
  status?: 'pending' | 'completed' | 'cancelled'
}

// 时间段查询参数类型
export interface AvailabilityParams {
  shopId: number
  stylistId?: number
  date: string
  serviceId: number
}

// 创建预约参数类型
export interface CreateAppointmentParams {
  shopId: number
  serviceId: number
  stylistId?: number
  appointmentDate: string
  appointmentTime: string
  notes?: string
}