import Router from 'koa-router'
import Joi from 'joi'
import { validate, schemas } from '../middleware/validate'
import { authenticate, optionalAuth } from '../middleware/auth'
import * as authController from '../controllers/authController'
import * as shopController from '../controllers/shopController'
import * as appointmentController from '../controllers/appointmentController'

const router = new Router({
  prefix: '/api/v1',
})

// ============ 认证路由 ============
const authRouter = new Router({ prefix: '/auth' })

// 登录/注册
authRouter.post(
  '/login',
  validate(
    Joi.object({
      phone: schemas.phone,
    })
  ),
  authController.login
)

// 发送验证码
authRouter.post(
  '/send-code',
  validate(
    Joi.object({
      phone: schemas.phone,
    })
  ),
  authController.sendVerificationCode
)

// 验证验证码
authRouter.post(
  '/verify',
  validate(
    Joi.object({
      phone: schemas.phone,
      code: schemas.code,
    })
  ),
  authController.verifyCode
)

// 获取用户信息（需要认证）
authRouter.get('/profile', authenticate, authController.getProfile)

// 更新用户信息（需要认证）
authRouter.put(
  '/profile',
  authenticate,
  validate(
    Joi.object({
      nickname: Joi.string().max(50).optional(),
      avatarUrl: Joi.string().uri().max(255).optional(),
    })
  ),
  authController.updateProfile
)

// 登出
authRouter.post('/logout', authenticate, authController.logout)

// ============ 店铺路由 ============
const shopRouter = new Router({ prefix: '/shops' })

// 获取店铺列表
shopRouter.get(
  '/',
  validate(
    Joi.object({
      search: Joi.string().optional(),
      latitude: Joi.number().optional(),
      longitude: Joi.number().optional(),
      radius: Joi.number().optional(),
      ...schemas.pagination,
    })
  ),
  shopController.getShops
)

// 获取店铺详情
shopRouter.get(
  '/:id',
  validate(
    Joi.object({
      id: schemas.id.required(),
    })
  ),
  shopController.getShopDetail
)

// 获取店铺服务列表
shopRouter.get(
  '/:id/services',
  validate(
    Joi.object({
      id: schemas.id.required(),
    })
  ),
  shopController.getShopServices
)

// 获取店铺理发师列表
shopRouter.get(
  '/:id/stylists',
  validate(
    Joi.object({
      id: schemas.id.required(),
    })
  ),
  shopController.getShopStylists
)

// ============ 预约路由 ============
const appointmentRouter = new Router({ prefix: '/appointments' })

// 获取可用时间段
router.get(
  '/availability',
  validate(
    Joi.object({
      shop_id: schemas.id.required(),
      service_id: schemas.id.required(),
      stylist_id: schemas.id.optional(),
      date: schemas.date.required(),
    })
  ),
  appointmentController.getAvailability
)

// 创建预约（需要认证）
appointmentRouter.post(
  '/',
  authenticate,
  validate(
    Joi.object({
      shop_id: Joi.number().integer().positive().required(),
      service_id: Joi.number().integer().positive().required(),
      stylist_id: Joi.number().integer().positive().optional().allow(null),
      appointment_date: schemas.date.required(),
      appointment_time: schemas.time.required(),
      notes: Joi.string().max(200).optional().allow(''),
    })
  ),
  appointmentController.createAppointment
)

// 获取用户预约列表（需要认证）
appointmentRouter.get(
  '/',
  authenticate,
  validate(
    Joi.object({
      status: Joi.string().valid('pending', 'completed', 'cancelled').optional(),
      ...schemas.pagination,
    })
  ),
  appointmentController.getAppointments
)

// 获取预约详情（需要认证）
appointmentRouter.get(
  '/:id',
  authenticate,
  validate(
    Joi.object({
      id: schemas.id.required(),
    })
  ),
  appointmentController.getAppointmentDetail
)

// 取消预约（需要认证）
appointmentRouter.put(
  '/:id/cancel',
  authenticate,
  validate(
    Joi.object({
      id: schemas.id.required(),
    })
  ),
  appointmentController.cancelAppointment
)

// ============ 健康检查路由 ============
router.get('/health', (ctx) => {
  ctx.body = {
    success: true,
    data: {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.APP_VERSION || '1.0.0',
    },
  }
})

// ============ 注册所有路由 ============
router.use(authRouter.routes(), authRouter.allowedMethods())
router.use(shopRouter.routes(), shopRouter.allowedMethods())
router.use(appointmentRouter.routes(), appointmentRouter.allowedMethods())

export default router