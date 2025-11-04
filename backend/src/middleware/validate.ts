import { Context, Next } from 'koa'
import Joi from 'joi'
import { badRequest } from '../utils/response'

// 通用验证中间件
export const validate = (schema: Joi.ObjectSchema) => {
  return async (ctx: Context, next: Next) => {
    try {
      // 合并所有可能的数据源
      const dataToValidate = {
        ...(ctx.request.body || {}),
        ...(ctx.params || {}),
        ...(ctx.query || {}),
      }

      // 验证数据
      const { error, value } = schema.validate(dataToValidate, {
        abortEarly: false,
        stripUnknown: true,
      })

      if (error) {
        const details = error.details.map((detail) => ({
          field: detail.path.join('.'),
          message: detail.message,
        }))

        badRequest(ctx, '数据验证失败', details)
        return
      }

      // 将验证后的数据附加到ctx上
      ctx.state.validated = value

      await next()
    } catch (err) {
      badRequest(ctx, '数据验证异常')
    }
  }
}

// 常用验证schema
export const schemas = {
  // 手机号验证
  phone: Joi.string()
    .pattern(/^1[3-9]\d{9}$/)
    .required()
    .messages({
      'string.pattern.base': '请输入正确的手机号码',
      'any.required': '手机号不能为空',
    }),

  // 验证码验证
  code: Joi.string()
    .length(6)
    .pattern(/^\d{6}$/)
    .messages({
      'string.length': '验证码必须是6位数字',
      'string.pattern.base': '验证码格式不正确',
    }),

  // 日期验证
  date: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .messages({
      'string.pattern.base': '日期格式应为 YYYY-MM-DD',
    }),

  // 时间验证
  time: Joi.string()
    .pattern(/^\d{2}:\d{2}(:\d{2})?$/)
    .messages({
      'string.pattern.base': '时间格式应为 HH:mm 或 HH:mm:ss',
    }),

  // ID验证
  id: Joi.number().integer().positive().messages({
    'number.base': 'ID必须是数字',
    'number.positive': 'ID必须是正数',
  }),

  // 分页参数
  pagination: {
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(10),
  },
}