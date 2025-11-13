import bcrypt from 'bcryptjs'
import dayjs from 'dayjs'
import customParseFormat from 'dayjs/plugin/customParseFormat'

dayjs.extend(customParseFormat)

// 生成随机确认码
export const generateConfirmationCode = (): string => {
  return Math.floor(10000000 + Math.random() * 90000000).toString()
}

// 密码加密
export const hashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(10)
  return bcrypt.hash(password, salt)
}

// 验证密码
export const comparePassword = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword)
}

// 格式化日期
export const formatDate = (date: Date | string, format: string = 'YYYY-MM-DD'): string => {
  return dayjs(date).format(format)
}

// 格式化时间
export const formatTime = (time: Date | string, format: string = 'HH:mm'): string => {
  return dayjs(time).format(format)
}

// 解析日期 - 明确指定格式避免时区问题
export const parseDate = (dateString: string): Date => {
  // 使用 UTC 模式解析日期字符串，避免时区偏移
  // 如果输入是 YYYY-MM-DD 格式，设置为当天的 00:00:00 UTC
  const parsed = dayjs(dateString, 'YYYY-MM-DD', true)
  if (!parsed.isValid()) {
    // 如果严格模式解析失败，尝试宽松模式
    return dayjs(dateString).toDate()
  }
  // 返回当天的开始时间（UTC）
  return parsed.toDate()
}

// 解析时间
export const parseTime = (timeString: string, baseDate?: string): Date => {
  const base = baseDate || dayjs().format('YYYY-MM-DD')
  return dayjs(`${base} ${timeString}`, 'YYYY-MM-DD HH:mm').toDate()
}

// 计算距离（简单实现，实际可用Haversine公式）
export const calculateDistance = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number => {
  const R = 6371 // 地球半径（公里）
  const dLat = deg2rad(lat2 - lat1)
  const dLon = deg2rad(lon2 - lon1)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  const distance = R * c
  return Math.round(distance * 1000) // 返回米
}

const deg2rad = (deg: number): number => {
  return deg * (Math.PI / 180)
}

// 检查时间是否在营业时间内
export const isWithinBusinessHours = (
  time: string,
  openingTime: string,
  closingTime: string
): boolean => {
  const timeMinutes = timeToMinutes(time)
  const openMinutes = timeToMinutes(openingTime)
  const closeMinutes = timeToMinutes(closingTime)
  return timeMinutes >= openMinutes && timeMinutes < closeMinutes
}

// 将时间转换为分钟数
const timeToMinutes = (time: string): number => {
  const [hours, minutes] = time.split(':').map(Number)
  return hours * 60 + minutes
}

// 添加时间（分钟）
export const addMinutes = (time: string, minutes: number): string => {
  const totalMinutes = timeToMinutes(time) + minutes
  const hours = Math.floor(totalMinutes / 60) % 24
  const mins = totalMinutes % 60
  return `${String(hours).padStart(2, '0')}:${String(mins).padStart(2, '0')}`
}

// 生成时间段
export const generateTimeSlots = (
  startTime: string,
  endTime: string,
  interval: number = 30
): string[] => {
  const slots: string[] = []
  let current = startTime

  while (timeToMinutes(current) < timeToMinutes(endTime)) {
    slots.push(current)
    current = addMinutes(current, interval)
  }

  return slots
}

// 验证手机号格式
export const isValidPhone = (phone: string): boolean => {
  const phoneRegex = /^1[3-9]\d{9}$/
  return phoneRegex.test(phone)
}

// 脱敏手机号
export const maskPhone = (phone: string): string => {
  if (phone.length !== 11) return phone
  return phone.substring(0, 3) + '****' + phone.substring(7)
}

// 分页参数处理
export const getPaginationParams = (query: any): { page: number; limit: number; skip: number } => {
  const page = Math.max(1, parseInt(query.page || '1', 10))
  const limit = Math.min(100, Math.max(1, parseInt(query.limit || '10', 10)))
  const skip = (page - 1) * limit

  return { page, limit, skip }
}

// 计算总页数
export const calculateTotalPages = (total: number, limit: number): number => {
  return Math.ceil(total / limit)
}