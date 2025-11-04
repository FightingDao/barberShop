import React, { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Loading, Toast, Button, Calendar } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { setDate, setTimeSlot, setAvailableTimeSlots, setLoadingTimeSlots } from '@/store/slices/bookingSlice'
import { bookingApi } from '@/services'
import { TimeSlot } from '@/types'

const SelectTimePage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shop, service, stylist, selectedDate, availableTimeSlots, isLoadingTimeSlots } = useAppSelector(
    state => state.booking
  )

  const [showCalendar, setShowCalendar] = useState(false)
  const [selectedSlot, setSelectedSlot] = useState<TimeSlot | null>(null)

  // 加载可用时间段
  useEffect(() => {
    if (selectedDate && shopId && service) {
      loadAvailableTimeSlots(selectedDate)
    }
  }, [selectedDate, shopId, service])

  const loadAvailableTimeSlots = async (date: string) => {
    if (!shopId || !service) return

    dispatch(setLoadingTimeSlots(true))
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

  const handleDateSelect = (value: Date | Date[]) => {
    const date = Array.isArray(value) ? value[0] : value
    const dateStr = date.toISOString().split('T')[0]
    dispatch(setDate(dateStr))
    setShowCalendar(false)
    setSelectedSlot(null)
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
    Toast.info('已选择时间')
    navigate(`/booking/confirm/${shopId}`)
  }

  const formatDate = (dateStr: string | null) => {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)

    if (date.toDateString() === today.toDateString()) {
      return '今天'
    } else if (date.toDateString() === tomorrow.toDateString()) {
      return '明天'
    } else {
      return date.toLocaleDateString('zh-CN', {
        month: 'long',
        day: 'numeric',
        weekday: 'short'
      })
    }
  }

  const formatDateDetail = (dateStr: string | null) => {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    return date.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      weekday: 'long'
    })
  }

  return (
    <div style={{ paddingBottom: '80px', background: '#f8f9fa', minHeight: '100vh' }}>
      <NavBar
        title="选择时间"
        onClickLeft={() => navigate(-1)}
      />

      <div style={{ padding: '16px' }}>
        {/* 预约信息摘要 */}
        <div style={{
          background: 'white',
          padding: '16px',
          borderRadius: '12px',
          marginBottom: '16px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h3 style={{ margin: '0 0 12px 0', fontSize: '16px', color: '#333', display: 'flex', alignItems: 'center' }}>
            <span style={{ marginRight: '8px' }}>📍</span>
            {shop?.name}
          </h3>
          <div style={{ fontSize: '14px', color: '#666', lineHeight: '1.8' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span>服务项目</span>
              <span style={{ fontWeight: 'bold', color: '#333' }}>{service?.name}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span>理发师</span>
              <span style={{ fontWeight: 'bold', color: '#333' }}>{stylist?.name || '不指定'}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
              <span>服务时长</span>
              <span style={{ fontWeight: 'bold', color: '#333' }}>{service?.duration}分钟</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>服务价格</span>
              <span style={{ fontSize: '18px', fontWeight: 'bold', color: '#ff6b6b' }}>¥{service?.price}</span>
            </div>
          </div>
        </div>

        {/* 日期选择 */}
        <div style={{
          background: 'white',
          padding: '16px',
          borderRadius: '12px',
          marginBottom: '16px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h4 style={{ margin: '0 0 12px 0', fontSize: '15px', color: '#333', display: 'flex', alignItems: 'center' }}>
            <span style={{ marginRight: '8px' }}>📅</span>
            选择日期
          </h4>
          <Button
            block
            type="primary"
            onClick={() => setShowCalendar(true)}
            style={{
              height: '48px',
              fontSize: '16px',
              background: selectedDate ? '#667eea' : '#f0f0f0',
              color: selectedDate ? 'white' : '#999',
              border: 'none',
              fontWeight: 'bold'
            }}
          >
            {selectedDate ? formatDateDetail(selectedDate) : '点击选择预约日期'}
          </Button>
        </div>

        {/* 时间段选择 */}
        {selectedDate && (
          <div style={{
            background: 'white',
            padding: '16px',
            borderRadius: '12px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
          }}>
            <h4 style={{ margin: '0 0 12px 0', fontSize: '15px', color: '#333', display: 'flex', alignItems: 'center' }}>
              <span style={{ marginRight: '8px' }}>⏰</span>
              选择时间段
            </h4>

            {isLoadingTimeSlots ? (
              <div style={{ padding: '40px 0', textAlign: 'center' }}>
                <Loading size="24px" />
                <p style={{ marginTop: '16px', color: '#999', fontSize: '14px' }}>
                  正在加载可用时间...
                </p>
              </div>
            ) : availableTimeSlots.length === 0 ? (
              <div style={{
                textAlign: 'center',
                padding: '40px 20px',
                background: '#fff9e6',
                borderRadius: '8px',
                border: '1px dashed #ffe58f'
              }}>
                <div style={{ fontSize: '48px', marginBottom: '12px' }}>😔</div>
                <p style={{ margin: '0 0 8px 0', color: '#d48806', fontSize: '15px', fontWeight: 'bold' }}>
                  当前日期无可用时间段
                </p>
                <p style={{ margin: 0, color: '#8c6d1f', fontSize: '13px' }}>
                  建议选择其他日期
                </p>
              </div>
            ) : (
              <>
                <p style={{ margin: '0 0 12px 0', fontSize: '13px', color: '#999' }}>
                  共{availableTimeSlots.length}个可选时间段，点击选择
                </p>
                <div style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(3, 1fr)',
                  gap: '12px'
                }}>
                  {availableTimeSlots.map((slot) => {
                    const isSelected = selectedSlot?.id === slot.id
                    return (
                      <div
                        key={slot.id}
                        onClick={() => handleTimeSlotSelect(slot)}
                        style={{
                          padding: '14px 8px',
                          textAlign: 'center',
                          borderRadius: '8px',
                          border: `2px solid ${isSelected ? '#667eea' : '#e0e0e0'}`,
                          background: isSelected ? '#f0f4ff' : 'white',
                          color: isSelected ? '#667eea' : '#333',
                          cursor: 'pointer',
                          transition: 'all 0.3s',
                          fontSize: '15px',
                          fontWeight: isSelected ? 'bold' : 'normal',
                          boxShadow: isSelected ? '0 4px 12px rgba(102, 126, 234, 0.3)' : 'none',
                          transform: isSelected ? 'scale(1.05)' : 'scale(1)'
                        }}
                      >
                        <div style={{ marginBottom: '4px', fontSize: '16px' }}>
                          {slot.startTime.substring(0, 5)}
                        </div>
                        {isSelected && (
                          <div style={{ fontSize: '12px', color: '#667eea' }}>
                            已选择
                          </div>
                        )}
                      </div>
                    )
                  })}
                </div>
              </>
            )}
          </div>
        )}

        {/* 提示信息 */}
        {!selectedDate && (
          <div style={{
            marginTop: '24px',
            padding: '16px',
            background: '#fff9e6',
            borderRadius: '8px',
            border: '1px solid #ffe58f'
          }}>
            <p style={{ margin: 0, fontSize: '14px', color: '#8c6d1f', lineHeight: '1.6' }}>
              💡 温馨提示：请先选择预约日期，系统将为您展示当日可用的时间段
            </p>
          </div>
        )}
      </div>

      {/* 底部确认按钮 */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        padding: '12px 16px',
        background: 'white',
        borderTop: '1px solid #f0f0f0',
        boxShadow: '0 -2px 8px rgba(0,0,0,0.05)'
      }}>
        {selectedSlot && (
          <div style={{
            marginBottom: '8px',
            padding: '8px 12px',
            background: '#f0f4ff',
            borderRadius: '8px',
            fontSize: '14px',
            color: '#667eea'
          }}>
            <span>已选时间：</span>
            <span style={{ fontWeight: 'bold' }}>
              {formatDate(selectedDate)} {selectedSlot.startTime.substring(0, 5)}
            </span>
          </div>
        )}
        <Button
          block
          type="primary"
          disabled={!selectedSlot}
          onClick={handleConfirm}
          style={{
            height: '48px',
            fontSize: '16px',
            fontWeight: 'bold',
            background: selectedSlot ? '#667eea' : '#d0d0d0',
            border: 'none'
          }}
        >
          {selectedSlot ? '下一步' : '请选择时间段'}
        </Button>
      </div>

      {/* 日历弹窗 */}
      <Calendar
        visible={showCalendar}
        onClose={() => setShowCalendar(false)}
        onConfirm={handleDateSelect}
        minDate={new Date()}
        maxDate={new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)}
        title="选择预约日期"
        confirmText="确认"
        confirmDisabledText="确认"
      />
    </div>
  )
}

export default SelectTimePage
