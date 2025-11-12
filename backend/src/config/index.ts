import dotenv from 'dotenv'
import path from 'path'

// 加载环境变量
dotenv.config({ path: path.join(__dirname, '../../.env') })

export const config = {
  // 服务器配置
  port: parseInt(process.env.PORT || '4000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  // 数据库配置
  databaseUrl: process.env.DATABASE_URL || '',

  // JWT配置
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  // CORS配置
  cors: {
    origins: (process.env.CORS_ORIGIN || 'http://localhost:4001').split(',').map(o => o.trim()),
  },

  // 日志配置
  logLevel: process.env.LOG_LEVEL || 'info',

  // 应用配置
  app: {
    name: process.env.APP_NAME || '理发店预约API',
    version: process.env.APP_VERSION || '1.0.0',
  },

  // 业务配置
  business: {
    // 预约取消时间限制（小时）
    cancelHoursLimit: 2,
    // 预约提前时间限制（分钟）
    advanceMinutesLimit: 30,
    // 默认营业时间
    defaultOpeningTime: '09:00',
    defaultClosingTime: '21:00',
    // 时间段粒度（分钟）
    timeSlotGranularity: 30,
  },
}

export default config