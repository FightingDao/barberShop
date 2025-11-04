import { Context } from 'koa'
import prisma from '../utils/db'
import { success, notFound } from '../utils/response'
import { getPaginationParams, calculateDistance } from '../utils/helpers'

// 获取店铺列表
export const getShops = async (ctx: Context) => {
  const { search, latitude, longitude, radius } = ctx.query
  const { page, limit, skip } = getPaginationParams(ctx.query)

  // 构建查询条件
  const where: any = {
    status: 'active',
  }

  // 搜索条件
  if (search) {
    where.OR = [
      { name: { contains: search as string, mode: 'insensitive' } },
      { address: { contains: search as string, mode: 'insensitive' } },
      { description: { contains: search as string, mode: 'insensitive' } },
    ]
  }

  // 获取总数
  const total = await prisma.shop.count({ where })

  // 获取店铺列表
  let shops = await prisma.shop.findMany({
    where,
    skip,
    take: limit,
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      name: true,
      address: true,
      phone: true,
      description: true,
      avatarUrl: true,
      openingTime: true,
      closingTime: true,
      latitude: true,
      longitude: true,
      status: true,
      createdAt: true,
      updatedAt: true,
    },
  })

  // 如果提供了用户位置，计算距离
  if (latitude && longitude) {
    const userLat = parseFloat(latitude as string)
    const userLon = parseFloat(longitude as string)

    shops = shops.map((shop) => {
      if (shop.latitude && shop.longitude) {
        const distance = calculateDistance(
          userLat,
          userLon,
          parseFloat(shop.latitude.toString()),
          parseFloat(shop.longitude.toString())
        )
        return { ...shop, distance }
      }
      return shop
    }) as any

    // 如果有半径限制，过滤店铺
    if (radius) {
      const radiusMeters = parseFloat(radius as string) * 1000
      shops = (shops as any).filter((shop: any) => !shop.distance || shop.distance <= radiusMeters)
    }

    // 按距离排序
    (shops as any).sort((a: any, b: any) => (a.distance || Infinity) - (b.distance || Infinity))
  }

  success(ctx, shops, undefined, { page, limit, total })
}

// 获取店铺详情
export const getShopDetail = async (ctx: Context) => {
  const shopId = parseInt(ctx.params.id, 10)

  const shop = await prisma.shop.findUnique({
    where: { id: shopId },
    include: {
      services: {
        where: { isActive: true },
        orderBy: { sortOrder: 'asc' },
      },
      stylists: {
        where: { status: 'active' },
      },
    },
  })

  if (!shop) {
    notFound(ctx, '店铺不存在')
    return
  }

  success(ctx, shop)
}

// 获取店铺服务列表
export const getShopServices = async (ctx: Context) => {
  const shopId = parseInt(ctx.params.id, 10)

  // 验证店铺是否存在
  const shop = await prisma.shop.findUnique({
    where: { id: shopId },
  })

  if (!shop) {
    notFound(ctx, '店铺不存在')
    return
  }

  const services = await prisma.service.findMany({
    where: {
      shopId,
      isActive: true,
    },
    orderBy: { sortOrder: 'asc' },
  })

  success(ctx, services)
}

// 获取店铺理发师列表
export const getShopStylists = async (ctx: Context) => {
  const shopId = parseInt(ctx.params.id, 10)

  // 验证店铺是否存在
  const shop = await prisma.shop.findUnique({
    where: { id: shopId },
  })

  if (!shop) {
    notFound(ctx, '店铺不存在')
    return
  }

  const stylists = await prisma.stylist.findMany({
    where: {
      shopId,
      status: 'active',
    },
  })

  success(ctx, stylists)
}