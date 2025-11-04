import React, { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Loading, Toast, Button } from 'react-vant'
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
  const [dateList, setDateList] = useState<Array<{ date: string; label: string; weekday: string }>>([])

  // 初始化日期列表
  useEffect(() => {
    const dates: Array<{ date: string; label: string; weekday: string }> = []
    const today = new Date()
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']

    for (let i = 0; i < 7; i++) {
      const date = new Date(today)
      date.setDate(date.getDate() + i)

      let label = ''
      if (i === 0) label = '今天'
      else if (i === 1) label = '明天'
      else label = `${date.getDate()}`

      dates.push({
        date: date.toISOString().split('T')[0],
        label,
        weekday: weekdays[date.getDay()]
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

  // 按上午/下午分组时间段
  const groupTimeSlots = () => {
    const morning: TimeSlot[] = []
    const afternoon: TimeSlot[] = []

    availableTimeSlots.forEach(slot => {
      const hour = parseInt(slot.startTime.split(':')[0])
      if (hour < 12) {
        morning.push(slot)
      } else {
        afternoon.push(slot)
      }
    })

    return { morning, afternoon }
  }

  const { morning, afternoon } = groupTimeSlots()

  return (
    <div style={{
      background: theme.colors.bgSecondary,
      minHeight: '100vh',
      paddingBottom: '100px'
    }}>
      {/* 顶部导航 */}
      <NavBar
        title="选择时间"
        leftText="返回"
        onClickLeft={() => navigate(-1)}
        style={{
          background: theme.colors.bgPrimary,
          boxShadow: theme.shadows.small
        }}
      />

      <div style={{ padding: theme.spacing.lg }}>
        {/* 预约信息卡片 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg,
          background: theme.colors.primaryLight
        }}>
          <div style={{
            fontSize: theme.fontSize.lg,
            fontWeight: 'bold',
            color: theme.colors.primary,
            marginBottom: theme.spacing.md
          }}>
            {shop?.name}
          </div>
          <div style={{
            fontSize: theme.fontSize.sm,
            color: theme.colors.textSecondary,
            lineHeight: '1.6'
          }}>
            <div style={{ marginBottom: theme.spacing.xs }}>
              <span>{service?.name}</span>
              <span style={{
                float: 'right',
                color: theme.colors.primary,
                fontWeight: 'bold'
              }}>
                ¥{service?.price}
              </span>
            </div>
            <div>
              <span>{stylist?.name || '不指定理发师'}</span>
              <span style={{
                float: 'right',
                color: theme.colors.textTertiary
              }}>
                {service?.duration}分钟
              </span>
            </div>
          </div>
        </div>

        {/* 日期选择 - 横向滚动 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg
        }}>
          <h4 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.md,
            fontWeight: 'bold',
            color: theme.colors.textPrimary
          }}>
            📅 选择日期
          </h4>
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
                    fontWeight: isSelected ? 'bold' : 'normal',
                    boxShadow: isSelected ? theme.shadows.primary : 'none'
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
          <div style={{
            ...commonStyles.card
          }}>
            <h4 style={{
              margin: `0 0 ${theme.spacing.lg} 0`,
              fontSize: theme.fontSize.md,
              fontWeight: 'bold',
              color: theme.colors.textPrimary
            }}>
              ⏰ 请选择您方便的预约时间
            </h4>

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
            ) : availableTimeSlots.length === 0 ? (
              <div style={{
                textAlign: 'center',
                padding: `${theme.spacing.xl} ${theme.spacing.lg}`,
                background: theme.colors.warning + '20',
                borderRadius: theme.borderRadius.medium,
                border: `1px dashed ${theme.colors.warning}`
              }}>
                <div style={{
                  fontSize: '48px',
                  marginBottom: theme.spacing.md,
                  color: theme.colors.warning
                }}>
                  😔
                </div>
                <p style={{
                  margin: `0 0 ${theme.spacing.sm} 0`,
                  color: theme.colors.warning,
                  fontSize: theme.fontSize.md,
                  fontWeight: 'bold'
                }}>
                  当前日期无可用时间段
                </p>
                <p style={{
                  margin: 0,
                  color: theme.colors.textTertiary,
                  fontSize: theme.fontSize.sm
                }}>
                  建议选择其他日期
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
                      {morning.map((slot) => {
                        const isSelected = selectedSlot?.id === slot.id
                        return (
                          <div
                            key={slot.id}
                            onClick={() => handleTimeSlotSelect(slot)}
                            style={{
                              padding: `${theme.spacing.md} ${theme.spacing.sm}`,
                              textAlign: 'center',
                              borderRadius: theme.borderRadius.small,
                              border: isSelected ? `2px solid ${theme.colors.primary}` : `1px solid ${theme.colors.borderLight}`,
                              background: isSelected ? theme.colors.primaryLight : theme.colors.bgPrimary,
                              color: isSelected ? theme.colors.primary : theme.colors.textPrimary,
                              cursor: 'pointer',
                              transition: 'all 0.3s ease',
                              fontSize: theme.fontSize.md,
                              fontWeight: isSelected ? 'bold' : 'normal'
                            }}
                          >
                            {slot.startTime.substring(0, 5)}
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
                      {afternoon.map((slot) => {
                        const isSelected = selectedSlot?.id === slot.id
                        return (
                          <div
                            key={slot.id}
                            onClick={() => handleTimeSlotSelect(slot)}
                            style={{
                              padding: `${theme.spacing.md} ${theme.spacing.sm}`,
                              textAlign: 'center',
                              borderRadius: theme.borderRadius.small,
                              border: isSelected ? `2px solid ${theme.colors.primary}` : `1px solid ${theme.colors.borderLight}`,
                              background: isSelected ? theme.colors.primaryLight : theme.colors.bgPrimary,
                              color: isSelected ? theme.colors.primary : theme.colors.textPrimary,
                              cursor: 'pointer',
                              transition: 'all 0.3s ease',
                              fontSize: theme.fontSize.md,
                              fontWeight: isSelected ? 'bold' : 'normal'
                            }}
                          >
                            {slot.startTime.substring(0, 5)}
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
            padding: `${theme.spacing.sm} ${theme.spacing.md}`,
            background: theme.colors.primaryLight,
            borderRadius: theme.borderRadius.small,
            fontSize: theme.fontSize.sm,
            color: theme.colors.primary
          }}>
            <span>已选：</span>
            <span style={{ fontWeight: 'bold' }}>
              {dateList.find(d => d.date === selectedDate)?.label} {selectedSlot.startTime.substring(0, 5)}
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
          {selectedSlot ? '下一步' : '请选择时间段'}
        </Button>
      </div>
    </div>
  )
}

export default SelectTimePage
