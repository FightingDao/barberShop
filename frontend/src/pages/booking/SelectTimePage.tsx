import React, { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Loading, Toast, Button } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { setDate, setTimeSlot, setAvailableTimeSlots, setLoadingTimeSlots } from '@/store/slices/bookingSlice'
import { bookingApi } from '@/services'
import { TimeSlot } from '@/types'
import { theme, commonStyles } from '@/styles/theme'

const SelectTimePage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shop, service, stylist, selectedDate, availableTimeSlots, isLoadingTimeSlots } = useAppSelector(
    state => state.booking
  )

  const [selectedSlot, setSelectedSlot] = useState<TimeSlot | null>(null)
  const [dateList, setDateList] = useState<Array<{ date: string; label: string; weekday: string; displayDate: string }>>([])

  // 初始化日期列表
  useEffect(() => {
    const dates: Array<{ date: string; label: string; weekday: string; displayDate: string }> = []
    const today = new Date()
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

    for (let i = 0; i < 7; i++) {
      const date = new Date(today)
      date.setDate(date.getDate() + i)

      let label = ''
      if (i === 0) label = '今天'
      else if (i === 1) label = '明天'
      else label = `${date.getDate()}`

      // 格式化显示日期：10月30日
      const month = date.getMonth() + 1
      const day = date.getDate()
      const displayDate = `${month}月${day}日`

      dates.push({
        date: date.toISOString().split('T')[0],
        label,
        weekday: weekdays[date.getDay()],
        displayDate
      })
    }
    setDateList(dates)

    // 默认选择今天
    if (!selectedDate) {
      dispatch(setDate(dates[0].date))
    }
  }, [])

  // 加载可用时间段
  useEffect(() => {
    if (selectedDate && shopId && service) {
      loadAvailableTimeSlots(selectedDate)
    }
  }, [selectedDate, shopId, service])

  const loadAvailableTimeSlots = async (date: string) => {
    if (!shopId || !service) return

    dispatch(setLoadingTimeSlots(true))
    setSelectedSlot(null)  // 切换日期时清空选择
    try {
      const response = await bookingApi.getAvailability({
        shopId: Number(shopId),
        serviceId: service.id,
        date,
        stylistId: stylist?.id,
      })

      if (response.success && response.data) {
        dispatch(setAvailableTimeSlots(response.data))
      } else {
        Toast.info(response.error?.message || '获取可用时间失败')
        dispatch(setAvailableTimeSlots([]))
      }
    } catch (error) {
      Toast.info('获取可用时间失败')
      dispatch(setAvailableTimeSlots([]))
    } finally {
      dispatch(setLoadingTimeSlots(false))
    }
  }

  const handleDateSelect = (date: string) => {
    dispatch(setDate(date))
  }

  const handleTimeSlotSelect = (slot: TimeSlot) => {
    if (!slot.isAvailable) return // 不可用的时间段不能选择
    setSelectedSlot(slot)
  }

  const handleConfirm = () => {
    if (!selectedSlot) {
      Toast.info('请选择时间段')
      return
    }

    dispatch(setTimeSlot(selectedSlot))
    navigate(`/booking/confirm/${shopId}`)
  }

  // 生成所有时间段（包括不可用的）
  const generateAllTimeSlots = () => {
    const slots: Array<{ time: string; slot?: TimeSlot }> = []
    const startHour = 9
    const endHour = 21
    
    // 创建所有时间段
    for (let hour = startHour; hour <= endHour; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        if (hour === endHour && minute > 0) break // 21:00之后不再生成
        
        const time = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`
        const slot = availableTimeSlots.find(s => s.startTime.substring(0, 5) === time)
        slots.push({ time, slot })
      }
    }
    
    return slots
  }

  // 按上午/下午分组时间段
  const groupTimeSlots = () => {
    const allSlots = generateAllTimeSlots()
    const morning: Array<{ time: string; slot?: TimeSlot }> = []
    const afternoon: Array<{ time: string; slot?: TimeSlot }> = []

    allSlots.forEach(item => {
      const hour = parseInt(item.time.split(':')[0])
      if (hour < 12) {
        morning.push(item)
      } else {
        afternoon.push(item)
      }
    })

    return { morning, afternoon }
  }

  const { morning, afternoon } = groupTimeSlots()

  // 格式化底部显示的日期
  const getSelectedDateDisplay = () => {
    if (!selectedDate || !selectedSlot) return ''
    const dateItem = dateList.find(d => d.date === selectedDate)
    if (dateItem) {
      return `${dateItem.displayDate} ${selectedSlot.startTime.substring(0, 5)}`
    }
    return ''
  }

  return (
    <div style={{
      background: theme.colors.bgPrimary,
      minHeight: '100vh',
      paddingBottom: '100px'
    }}>
      {/* 自定义顶部导航 */}
      <div style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 100,
        background: theme.colors.bgPrimary,
        boxShadow: theme.shadows.small,
        padding: `${theme.spacing.md} ${theme.spacing.lg}`,
        paddingBottom: theme.spacing.sm
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          marginBottom: theme.spacing.xs
        }}>
          <div
            onClick={() => navigate(-1)}
            style={{
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: theme.colors.bgSecondary,
              borderRadius: theme.borderRadius.round,
              cursor: 'pointer',
              marginRight: theme.spacing.md
            }}
          >
            <span style={{ fontSize: '18px' }}>←</span>
          </div>
          <h2 style={{
            margin: 0,
            fontSize: theme.fontSize.lg,
            fontWeight: 'bold',
            color: theme.colors.textPrimary
          }}>
            选择时间
          </h2>
        </div>
        <p style={{
          margin: `0 0 0 ${32 + theme.spacing.md}px`,
          fontSize: theme.fontSize.sm,
          color: theme.colors.textTertiary
        }}>
          请选择您方便的预约时间
        </p>
      </div>

      <div style={{ 
        padding: theme.spacing.lg,
        paddingTop: '70px' // 为固定的topbar留出空间
      }}>
        {/* 日期选择 - 横向滚动 */}
        <div style={{
          marginBottom: theme.spacing.lg
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            marginBottom: theme.spacing.md
          }}>
            <span style={{ fontSize: '16px', marginRight: theme.spacing.xs }}>📅</span>
            <h4 style={{
              margin: 0,
              fontSize: theme.fontSize.md,
              fontWeight: 'bold',
              color: theme.colors.textPrimary
            }}>
              选择日期
            </h4>
          </div>
          <div style={{
            display: 'flex',
            overflowX: 'auto',
            gap: theme.spacing.md,
            paddingBottom: theme.spacing.xs,
            WebkitOverflowScrolling: 'touch',
            scrollbarWidth: 'none',
            msOverflowStyle: 'none'
          }}>
            {dateList.map((item) => {
              const isSelected = selectedDate === item.date
              return (
                <div
                  key={item.date}
                  onClick={() => handleDateSelect(item.date)}
                  style={{
                    flex: '0 0 auto',
                    width: '70px',
                    padding: `${theme.spacing.md} ${theme.spacing.sm}`,
                    textAlign: 'center',
                    borderRadius: theme.borderRadius.medium,
                    background: isSelected ? theme.colors.primary : theme.colors.bgTertiary,
                    color: isSelected ? theme.colors.bgPrimary : theme.colors.textSecondary,
                    cursor: 'pointer',
                    transition: 'all 0.3s ease',
                    fontWeight: isSelected ? 'bold' : 'normal'
                  }}
                >
                  <div style={{
                    fontSize: theme.fontSize.lg,
                    marginBottom: theme.spacing.xs
                  }}>
                    {item.label}
                  </div>
                  <div style={{
                    fontSize: theme.fontSize.xs,
                    opacity: 0.8
                  }}>
                    {item.weekday}
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* 时间段选择 */}
        {selectedDate && (
          <div>
            {isLoadingTimeSlots ? (
              <div style={commonStyles.loadingCenter}>
                <Loading size="24px" color={theme.colors.primary} />
                <p style={{
                  marginTop: theme.spacing.lg,
                  color: theme.colors.textTertiary,
                  fontSize: theme.fontSize.sm
                }}>
                  正在加载可用时间...
                </p>
              </div>
            ) : (
              <>
                {/* 上午时间段 */}
                {morning.length > 0 && (
                  <div style={{ marginBottom: theme.spacing.xxl }}>
                    <h5 style={{
                      margin: `0 0 ${theme.spacing.md} 0`,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textTertiary,
                      fontWeight: 'normal'
                    }}>
                      上午
                    </h5>
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: 'repeat(3, 1fr)',
                      gap: theme.spacing.md
                    }}>
                      {morning.map((item) => {
                        // 使用startTime来匹配选中状态，因为API返回的时间段没有id
                        const isSelected = selectedSlot?.startTime?.substring(0, 5) === item.time
                        const isAvailable = item.slot?.isAvailable === true
                        return (
                          <div
                            key={item.time}
                            onClick={() => item.slot && isAvailable && handleTimeSlotSelect(item.slot)}
                            style={{
                              padding: `${theme.spacing.md} ${theme.spacing.sm}`,
                              textAlign: 'center',
                              borderRadius: theme.borderRadius.medium,
                              background: isSelected 
                                ? theme.colors.primary 
                                : isAvailable 
                                  ? theme.colors.bgPrimary 
                                  : theme.colors.bgTertiary,
                              color: isSelected 
                                ? theme.colors.bgPrimary 
                                : isAvailable 
                                  ? theme.colors.textSecondary 
                                  : theme.colors.textDisabled,
                              cursor: isAvailable ? 'pointer' : 'not-allowed',
                              transition: 'all 0.3s ease',
                              fontSize: theme.fontSize.md,
                              border: `1px solid ${isSelected ? theme.colors.primary : isAvailable ? theme.colors.borderLight : theme.colors.bgTertiary}`,
                              fontWeight: isSelected ? 'bold' : 'normal'
                            }}
                          >
                            {item.time}
                          </div>
                        )
                      })}
                    </div>
                  </div>
                )}

                {/* 下午时间段 */}
                {afternoon.length > 0 && (
                  <div>
                    <h5 style={{
                      margin: `0 0 ${theme.spacing.md} 0`,
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textTertiary,
                      fontWeight: 'normal'
                    }}>
                      下午
                    </h5>
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: 'repeat(3, 1fr)',
                      gap: theme.spacing.md
                    }}>
                      {afternoon.map((item) => {
                        // 使用startTime来匹配选中状态，因为API返回的时间段没有id
                        const isSelected = selectedSlot?.startTime?.substring(0, 5) === item.time
                        const isAvailable = item.slot?.isAvailable === true
                        return (
                          <div
                            key={item.time}
                            onClick={() => item.slot && isAvailable && handleTimeSlotSelect(item.slot)}
                            style={{
                              padding: `${theme.spacing.md} ${theme.spacing.sm}`,
                              textAlign: 'center',
                              borderRadius: theme.borderRadius.medium,
                              background: isSelected 
                                ? theme.colors.primary 
                                : isAvailable 
                                  ? theme.colors.bgPrimary 
                                  : theme.colors.bgTertiary,
                              color: isSelected 
                                ? theme.colors.bgPrimary 
                                : isAvailable 
                                  ? theme.colors.textSecondary 
                                  : theme.colors.textDisabled,
                              cursor: isAvailable ? 'pointer' : 'not-allowed',
                              transition: 'all 0.3s ease',
                              fontSize: theme.fontSize.md,
                              border: `1px solid ${isSelected ? theme.colors.primary : isAvailable ? theme.colors.borderLight : theme.colors.bgTertiary}`,
                              fontWeight: isSelected ? 'bold' : 'normal'
                            }}
                          >
                            {item.time}
                          </div>
                        )
                      })}
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        )}
      </div>

      {/* 底部确认按钮 */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        padding: theme.spacing.lg,
        background: theme.colors.bgPrimary,
        borderTop: `1px solid ${theme.colors.borderLight}`,
        boxShadow: theme.shadows.large
      }}>
        {selectedSlot && selectedDate && (
          <div style={{
            marginBottom: theme.spacing.md,
            fontSize: theme.fontSize.sm,
            color: theme.colors.textSecondary
          }}>
            <span>已选: </span>
            <span style={{ fontWeight: 'bold', color: theme.colors.textPrimary }}>
              {getSelectedDateDisplay()}
            </span>
          </div>
        )}
        <Button
          block
          round
          disabled={!selectedSlot}
          onClick={handleConfirm}
          style={{
            ...commonStyles.primaryButton,
            opacity: selectedSlot ? 1 : 0.6,
            cursor: selectedSlot ? 'pointer' : 'not-allowed'
          }}
        >
          下一步
        </Button>
      </div>
    </div>
  )
}

export default SelectTimePage
