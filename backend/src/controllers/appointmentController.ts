import { Context } from 'koa'
import prisma from '../utils/db'
import { success, badRequest, notFound, conflict } from '../utils/response'
import {
  generateConfirmationCode,
  getPaginationParams,
  formatDate,
  formatTime,
  parseDate,
  parseTime,
  addMinutes,
  isWithinBusinessHours
} from '../utils/helpers'
import dayjs from 'dayjs'
import config from '../config'

// 获取可用时间段
export const getAvailability = async (ctx: Context) => {
  const { shop_id, stylist_id, date, service_id } = ctx.query

  const shopId = parseInt(shop_id as string, 10)
  const serviceId = parseInt(service_id as string, 10)
  const stylistId = stylist_id ? parseInt(stylist_id as string, 10) : undefined
  const queryDate = date as string

  // 验证店铺和服务
  const shop = await prisma.shop.findUnique({ where: { id: shopId } })
  if (!shop) {
    notFound(ctx, '店铺不存在')
    return
  }

  const service = await prisma.service.findUnique({ where: { id: serviceId } })
  if (!service) {
    notFound(ctx, '服务不存在')
    return
  }

  // 获取营业时间
  const openingTime = formatTime(shop.openingTime)
  const closingTime = formatTime(shop.closingTime)

  // 查询已预约的时间段
  const appointments = await prisma.appointment.findMany({
    where: {
      shopId,
      appointmentDate: parseDate(queryDate),
      status: { in: ['pending', 'completed'] },
      ...(stylistId && { stylistId }),
    },
  })

  // 生成所有可能的时间段
  const allSlots: any[] = []
  let currentTime = openingTime

  while (currentTime < closingTime) {
    const endTime = addMinutes(currentTime, config.business.timeSlotGranularity)
    const slotEndWithService = addMinutes(currentTime, service.durationMinutes)

    // 检查时间段是否在营业时间内
    if (slotEndWithService <= closingTime) {
      // 检查是否与现有预约冲突
      const isBooked = appointments.some((apt) => {
        const aptTime = formatTime(apt.appointmentTime)
        const aptEndTime = addMinutes(aptTime, apt.durationMinutes)

        return (
          (currentTime >= aptTime && currentTime < aptEndTime) ||
          (slotEndWithService > aptTime && slotEndWithService <= aptEndTime) ||
          (currentTime <= aptTime && slotEndWithService >= aptEndTime)
        )
      })

      // 检查是否是过去的时间
      const isPast = dayjs(`${queryDate} ${currentTime}`).isBefore(dayjs())

      allSlots.push({
        date: queryDate,
        startTime: currentTime,
        endTime: addMinutes(currentTime, service.durationMinutes),
        isAvailable: !isBooked && !isPast,
        status: isPast ? 'expired' : isBooked ? 'booked' : 'available',
      })
    }

    currentTime = endTime
  }

  success(ctx, allSlots)
}

// 创建预约
export const createAppointment = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const {
    shop_id,
    service_id,
    stylist_id,
    appointment_date,
    appointment_time,
    notes,
  } = ctx.state.validated

  const shopId = parseInt(shop_id, 10)
  const serviceId = parseInt(service_id, 10)
  const stylistId = stylist_id ? parseInt(stylist_id, 10) : null

  // 验证店铺
  const shop = await prisma.shop.findUnique({ where: { id: shopId } })
  if (!shop) {
    notFound(ctx, '店铺不存在')
    return
  }

  // 验证服务
  const service = await prisma.service.findUnique({ where: { id: serviceId } })
  if (!service) {
    notFound(ctx, '服务不存在')
    return
  }

  // 验证理发师（如果指定）
  if (stylistId) {
    const stylist = await prisma.stylist.findUnique({ where: { id: stylistId } })
    if (!stylist || stylist.shopId !== shopId) {
      notFound(ctx, '理发师不存在')
      return
    }
  }

  // 检查预约时间是否有效
  const appointmentDateTime = dayjs(`${appointment_date} ${appointment_time}`)
  const now = dayjs()

  if (appointmentDateTime.isBefore(now.add(config.business.advanceMinutesLimit, 'minute'))) {
    badRequest(ctx, `预约时间必须提前至少${config.business.advanceMinutesLimit}分钟`)
    return
  }

  // 检查时间段是否已被预约（使用事务确保原子性）
  try {
    const appointment = await prisma.$transaction(async (tx) => {
      // 再次检查时间段可用性
      const conflictingAppointments = await tx.appointment.findMany({
        where: {
          shopId,
          appointmentDate: parseDate(appointment_date),
          status: { in: ['pending', 'completed'] },
          ...(stylistId && { stylistId }),
        },
      })

      const isConflict = conflictingAppointments.some((apt) => {
        const aptTime = formatTime(apt.appointmentTime)
        const aptEndTime = addMinutes(aptTime, apt.durationMinutes)
        const newEndTime = addMinutes(appointment_time, service.durationMinutes)

        return (
          (appointment_time >= aptTime && appointment_time < aptEndTime) ||
          (newEndTime > aptTime && newEndTime <= aptEndTime) ||
          (appointment_time <= aptTime && newEndTime >= aptEndTime)
        )
      })

      if (isConflict) {
        throw new Error('CONFLICT')
      }

      // 创建预约
      const newAppointment = await tx.appointment.create({
        data: {
          userId,
          shopId,
          serviceId,
          stylistId,
          appointmentDate: parseDate(appointment_date),
          appointmentTime: parseTime(appointment_time, appointment_date),
          durationMinutes: service.durationMinutes,
          notes: notes || null,
          confirmationCode: generateConfirmationCode(),
          status: 'pending',
        },
        include: {
          shop: true,
          service: true,
          stylist: true,
        },
      })

      return newAppointment
    })

    // 格式化日期和时间字段
    const formattedAppointment = {
      ...appointment,
      appointmentDate: formatDate(appointment.appointmentDate),
      appointmentTime: formatTime(appointment.appointmentTime),
    }

    success(ctx, formattedAppointment, '预约成功', undefined)
  } catch (error: any) {
    if (error.message === 'CONFLICT') {
      conflict(ctx, '该时间段已被预约，请选择其他时间')
    } else {
      throw error
    }
  }
}

// 获取用户预约列表
export const getAppointments = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const { status } = ctx.query
  const { page, limit, skip } = getPaginationParams(ctx.query)

  // 构建查询条件
  const where: any = { userId }
  if (status) {
    where.status = status
  }

  // 获取总数
  const total = await prisma.appointment.count({ where })

  // 获取预约列表
  const appointments = await prisma.appointment.findMany({
    where,
    skip,
    take: limit,
    orderBy: [
      { appointmentDate: 'desc' },
      { appointmentTime: 'desc' },
    ],
    include: {
      shop: {
        select: {
          id: true,
          name: true,
          address: true,
          phone: true,
          avatarUrl: true,
          status: true,
        },
      },
      service: {
        select: {
          id: true,
          name: true,
          price: true,
          durationMinutes: true,
        },
      },
      stylist: {
        select: {
          id: true,
          name: true,
          avatarUrl: true,
          title: true,
          status: true,
        },
      },
    },
  })

  // 格式化日期和时间字段
  const formattedAppointments = appointments.map((apt) => ({
    ...apt,
    appointmentDate: formatDate(apt.appointmentDate),
    appointmentTime: formatTime(apt.appointmentTime),
  }))

  success(ctx, formattedAppointments, undefined, { page, limit, total })
}

// 获取预约详情
export const getAppointmentDetail = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const appointmentId = parseInt(ctx.params.id, 10)

  const appointment = await prisma.appointment.findFirst({
    where: {
      id: appointmentId,
      userId,
    },
    include: {
      shop: true,
      service: true,
      stylist: true,
    },
  })

  if (!appointment) {
    notFound(ctx, '预约不存在')
    return
  }

  // 格式化日期和时间字段
  const formattedAppointment = {
    ...appointment,
    appointmentDate: formatDate(appointment.appointmentDate),
    appointmentTime: formatTime(appointment.appointmentTime),
  }

  success(ctx, formattedAppointment)
}

// 取消预约
export const cancelAppointment = async (ctx: Context) => {
  if (!ctx.state.user) {
    badRequest(ctx, '用户未登录')
    return
  }

  const userId = ctx.state.user.id

  const appointmentId = parseInt(ctx.params.id, 10)

  // 查找预约
  const appointment = await prisma.appointment.findFirst({
    where: {
      id: appointmentId,
      userId,
    },
  })

  if (!appointment) {
    notFound(ctx, '预约不存在')
    return
  }

  // 检查预约状态
  if (appointment.status !== 'pending') {
    badRequest(ctx, '该预约无法取消')
    return
  }

  // 检查取消时间限制 - 暂时禁用
  // const appointmentDateTime = dayjs(
  //   `${formatDate(appointment.appointmentDate)} ${formatTime(appointment.appointmentTime)}`
  // )
  // const now = dayjs()
  // const hoursDiff = appointmentDateTime.diff(now, 'hour')

  // if (hoursDiff < config.business.cancelHoursLimit) {
  //   badRequest(ctx, `距离预约时间不足${config.business.cancelHoursLimit}小时，无法取消`)
  //   return
  // }

  // 更新预约状态
  await prisma.appointment.update({
    where: { id: appointmentId },
    data: { status: 'cancelled' },
  })

  success(ctx, null, '预约已取消')
}