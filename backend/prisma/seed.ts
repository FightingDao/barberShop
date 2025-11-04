import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'
import dayjs from 'dayjs'

const prisma = new PrismaClient()

async function main() {
  console.log('开始种子数据初始化...')

  // 清理现有数据
  await prisma.timeSlot.deleteMany()
  await prisma.appointment.deleteMany()
  await prisma.stylist.deleteMany()
  await prisma.service.deleteMany()
  await prisma.shop.deleteMany()
  await prisma.user.deleteMany()

  // 创建测试用户
  const hashedPassword = await bcrypt.hash('123456', 10)
  const testUser = await prisma.user.create({
    data: {
      phone: '13800138000',
      nickname: '测试用户',
      avatarUrl: 'https://placehold.co/100x100/png?text=用户头像',
    },
  })

  console.log('✓ 创建测试用户:', testUser.phone)

  // 创建测试店铺
  const shops = await Promise.all([
    prisma.shop.create({
      data: {
        name: '风尚造型理发店',
        address: '北京市朝阳区三里屯路19号',
        phone: '010-12345678',
        description: '专业时尚理发店，拥有经验丰富的发型师团队，为您提供个性化的发型设计服务。',
        avatarUrl: 'https://placehold.co/200x200/png?text=风尚造型',
        openingTime: new Date('2024-01-01T09:00:00'),
        closingTime: new Date('2024-01-01T21:00:00'),
        latitude: 39.9343,
        longitude: 116.4477,
        status: 'active',
      },
    }),
    prisma.shop.create({
      data: {
        name: '潮流理发沙龙',
        address: '北京市海淀区中关村大街1号',
        phone: '010-87654321',
        description: '现代化理发沙龙，采用国际先进设备和理发技术，打造专属您的时尚造型。',
        avatarUrl: 'https://placehold.co/200x200/png?text=潮流沙龙',
        openingTime: new Date('2024-01-01T10:00:00'),
        closingTime: new Date('2024-01-01T22:00:00'),
        latitude: 39.9042,
        longitude: 116.4074,
        status: 'active',
      },
    }),
    prisma.shop.create({
      data: {
        name: '艺剪坊',
        address: '北京市东城区王府井大街255号',
        phone: '010-11223344',
        description: '传统与现代结合的理发店，提供经典剪发和时尚造型服务。',
        avatarUrl: 'https://placehold.co/200x200/png?text=艺剪坊',
        openingTime: new Date('2024-01-01T09:30:00'),
        closingTime: new Date('2024-01-01T20:30:00'),
        latitude: 39.9139,
        longitude: 116.4074,
        status: 'active',
      },
    }),
  ])

  console.log('✓ 创建店铺数量:', shops.length)

  // 为每个店铺创建服务项目
  for (const shop of shops) {
    const services = await Promise.all([
      prisma.service.create({
        data: {
          shopId: shop.id,
          name: '经典剪发',
          description: '基础剪发服务，包括洗发和造型',
          price: 38.00,
          durationMinutes: 45,
          iconUrl: 'https://placehold.co/50x50/png?text=剪发',
          sortOrder: 1,
          isActive: true,
        },
      }),
      prisma.service.create({
        data: {
          shopId: shop.id,
          name: '洗剪吹套餐',
          description: '全面护理套餐，包含深层清洁、精准剪裁和吹风造型',
          price: 68.00,
          durationMinutes: 60,
          iconUrl: 'https://placehold.co/50x50/png?text=洗剪吹',
          sortOrder: 2,
          isActive: true,
        },
      }),
      prisma.service.create({
        data: {
          shopId: shop.id,
          name: '精剪造型',
          description: '个性化精剪服务，根据脸型和需求设计专属发型',
          price: 98.00,
          durationMinutes: 75,
          iconUrl: 'https://placehold.co/50x50/png?text=精剪',
          sortOrder: 3,
          isActive: true,
        },
      }),
      prisma.service.create({
        data: {
          shopId: shop.id,
          name: '染发服务',
          description: '专业染发服务，使用进口染发剂，颜色持久亮丽',
          price: 188.00,
          durationMinutes: 120,
          iconUrl: 'https://placehold.co/50x50/png?text=染发',
          sortOrder: 4,
          isActive: true,
        },
      }),
      prisma.service.create({
        data: {
          shopId: shop.id,
          name: '烫发造型',
          description: '时尚烫发服务，打造持久卷曲造型',
          price: 288.00,
          durationMinutes: 150,
          iconUrl: 'https://placehold.co/50x50/png?text=烫发',
          sortOrder: 5,
          isActive: true,
        },
      }),
    ])

    console.log(`✓ 店铺 ${shop.name} 创建服务数量:`, services.length)

    // 创建理发师
    const stylists = await Promise.all([
      prisma.stylist.create({
        data: {
          shopId: shop.id,
          name: '张师傅',
          avatarUrl: 'https://placehold.co/100x100/png?text=张师傅',
          title: '高级发型师',
          experienceYears: 8,
          specialties: '精剪造型,染发,烫发',
          status: 'active',
        },
      }),
      prisma.stylist.create({
        data: {
          shopId: shop.id,
          name: '李师傅',
          avatarUrl: 'https://placehold.co/100x100/png?text=李师傅',
          title: '资深发型师',
          experienceYears: 12,
          specialties: '经典剪发,男士造型,儿童理发',
          status: 'active',
        },
      }),
      prisma.stylist.create({
        data: {
          shopId: shop.id,
          name: '王师傅',
          avatarUrl: 'https://placehold.co/100x100/png?text=王师傅',
          title: '创意总监',
          experienceYears: 15,
          specialties: '创意染发,时尚烫发,整体造型',
          status: 'active',
        },
      }),
      prisma.stylist.create({
        data: {
          shopId: shop.id,
          name: '刘师傅',
          avatarUrl: 'https://placehold.co/100x100/png?text=刘师傅',
          title: '助理发型师',
          experienceYears: 3,
          specialties: '基础剪发,洗发护发',
          status: 'active',
        },
      }),
    ])

    console.log(`✓ 店铺 ${shop.name} 创建理发师数量:`, stylists.length)

    // 生成未来7天的时间段
    const today = dayjs()
    for (let dayOffset = 0; dayOffset < 7; dayOffset++) {
      const currentDate = today.add(dayOffset, 'day')

      // 为每个理发师生成时间段
      for (const stylist of stylists) {
        const openingTime = dayjs(`${currentDate.format('YYYY-MM-DD')} ${shop.openingTime.toTimeString().slice(0, 5)}`)
        const closingTime = dayjs(`${currentDate.format('YYYY-MM-DD')} ${shop.closingTime.toTimeString().slice(0, 5)}`)

        let currentTime = openingTime

        while (currentTime.isBefore(closingTime)) {
          const endTime = currentTime.add(30, 'minute')

          // 只创建未来的时间段
          if (endTime.isAfter(dayjs())) {
            await prisma.timeSlot.create({
              data: {
                shopId: shop.id,
                stylistId: stylist.id,
                date: currentDate.toDate(),
                startTime: currentTime.toDate(),
                endTime: endTime.toDate(),
                isAvailable: true,
              },
            })
          }

          currentTime = endTime
        }
      }
    }

    console.log(`✓ 店铺 ${shop.name} 生成时间段完成`)
  }

  // 创建一些示例预约
  const futureDate = dayjs().add(2, 'day').format('YYYY-MM-DD')
  const futureTime = '14:00:00'

  await prisma.appointment.create({
    data: {
      userId: testUser.id,
      shopId: shops[0].id,
      serviceId: 1, // 经典剪发
      stylistId: 1, // 张师傅
      appointmentDate: new Date(futureDate),
      appointmentTime: new Date(`${futureDate}T${futureTime}`),
      durationMinutes: 45,
      status: 'pending',
      notes: '请稍微剪短一些',
      confirmationCode: generateConfirmationCode(),
    },
  })

  console.log('✓ 创建示例预约完成')

  console.log('🎉 种子数据初始化完成!')
}

// 生成预约确认码
function generateConfirmationCode(): string {
  return Math.floor(10000000 + Math.random() * 90000000).toString()
}

main()
  .catch((e) => {
    console.error('种子数据初始化失败:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })