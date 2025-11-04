import React, { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Button, Field, Dialog, Notify } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { setNotes, resetBookingFlow } from '@/store/slices/bookingSlice'
import { bookingApi } from '@/services'

const ConfirmBookingPage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shop, service, stylist, selectedDate, timeSlot, notes } = useAppSelector(
    state => state.booking
  )
  const { user } = useAppSelector(state => state.auth)

  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleNotesChange = (value: string) => {
    dispatch(setNotes(value))
  }

  const handleGoBack = () => {
    navigate(-1)
  }

  const handleConfirmBooking = async () => {
    if (!shopId || !service || !selectedDate || !timeSlot) {
      Notify.show({ type: 'warning', message: '预约信息不完整' })
      return
    }

    // 确认对话框
    const result = await Dialog.confirm({
      title: '确认预约',
      message: '请确认预约信息无误后提交',
    })

    if (!result) return

    setIsSubmitting(true)
    try {
      const response = await bookingApi.createAppointment({
        shopId: Number(shopId),
        serviceId: service.id,
        stylistId: stylist?.id,
        appointmentDate: selectedDate,
        appointmentTime: timeSlot.startTime,
        notes: notes || undefined,
      })

      if (response.success && response.data) {
        Notify.show({ type: 'success', message: '预约成功！' })
        dispatch(resetBookingFlow())
        navigate('/booking/success')
      } else {
        Notify.show({ type: 'danger', message: response.error?.message || '预约失败' })
      }
    } catch (error) {
      console.error('预约失败:', error)
      Notify.show({ type: 'danger', message: '预约失败，请重试' })
    } finally {
      setIsSubmitting(false)
    }
  }

  const formatDate = (dateStr: string | null) => {
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
    <div style={{ paddingBottom: '100px', background: '#f8f9fa', minHeight: '100vh' }}>
      <NavBar
        title="确认预约"
        onClickLeft={handleGoBack}
      />

      <div style={{ padding: '16px' }}>
        {/* 预约信息确认 */}
        <div style={{
          background: 'white',
          padding: '16px',
          borderRadius: '12px',
          marginBottom: '16px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h3 style={{
            margin: '0 0 16px 0',
            fontSize: '18px',
            color: '#333',
            borderBottom: '2px solid #667eea',
            paddingBottom: '12px',
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: '8px' }}>📋</span>
            预约信息
          </h3>

          <div style={{ lineHeight: '2.4' }}>
            <div style={{ display: 'flex', marginBottom: '12px', background: '#f8f9fa', padding: '8px 12px', borderRadius: '6px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>店铺名称</span>
              <span style={{ fontWeight: '600', color: '#333' }}>{shop?.name}</span>
            </div>

            <div style={{ display: 'flex', marginBottom: '12px', padding: '8px 12px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>店铺地址</span>
              <span style={{ fontSize: '14px', color: '#666' }}>{shop?.address}</span>
            </div>

            <div style={{ display: 'flex', marginBottom: '12px', background: '#f8f9fa', padding: '8px 12px', borderRadius: '6px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>服务项目</span>
              <span style={{ fontWeight: '600', color: '#333' }}>{service?.name}</span>
            </div>

            <div style={{ display: 'flex', marginBottom: '12px', padding: '8px 12px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>理发师</span>
              <span style={{ fontWeight: '600', color: '#333' }}>{stylist?.name || '不指定'}</span>
            </div>

            <div style={{ display: 'flex', marginBottom: '12px', background: '#f8f9fa', padding: '8px 12px', borderRadius: '6px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>预约时间</span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', color: '#333', marginBottom: '4px' }}>
                  {formatDate(selectedDate)}
                </div>
                <div style={{ fontSize: '14px', color: '#667eea', fontWeight: 'bold' }}>
                  {timeSlot?.startTime?.substring(0, 5)}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', marginBottom: '12px', padding: '8px 12px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>服务时长</span>
              <span style={{ color: '#666' }}>{service?.duration}分钟</span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', background: '#fff9e6', padding: '12px', borderRadius: '6px', border: '1px solid #ffe58f' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>服务价格</span>
              <span style={{ fontSize: '24px', fontWeight: 'bold', color: '#ff6b6b' }}>
                ¥{service?.price}
              </span>
            </div>
          </div>
        </div>

        {/* 联系信息 */}
        <div style={{
          background: 'white',
          padding: '16px',
          borderRadius: '12px',
          marginBottom: '16px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h3 style={{
            margin: '0 0 16px 0',
            fontSize: '18px',
            color: '#333',
            borderBottom: '2px solid #667eea',
            paddingBottom: '12px',
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: '8px' }}>👤</span>
            联系信息
          </h3>

          <div style={{ lineHeight: '2.4' }}>
            <div style={{ display: 'flex', marginBottom: '12px', background: '#f8f9fa', padding: '8px 12px', borderRadius: '6px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>姓名</span>
              <span style={{ fontWeight: '600', color: '#333' }}>{user?.nickname || '用户'}</span>
            </div>

            <div style={{ display: 'flex', padding: '8px 12px' }}>
              <span style={{ color: '#999', width: '90px', flexShrink: 0 }}>手机号</span>
              <span style={{ fontWeight: '600', color: '#333' }}>{user?.phone}</span>
            </div>
          </div>
        </div>

        {/* 备注 */}
        <div style={{
          background: 'white',
          padding: '16px',
          borderRadius: '12px',
          marginBottom: '16px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h3 style={{
            margin: '0 0 12px 0',
            fontSize: '18px',
            color: '#333',
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: '8px' }}>📝</span>
            备注信息
            <span style={{ fontSize: '14px', color: '#999', fontWeight: 'normal', marginLeft: '8px' }}>(可选)</span>
          </h3>
          <Field
            value={notes}
            onChange={handleNotesChange}
            rows={3}
            autoSize
            type="textarea"
            maxLength={200}
            placeholder="请输入备注信息，如特殊需求、发型要求等"
            showWordLimit
            style={{
              background: '#f8f9fa',
              borderRadius: '8px',
              padding: '12px'
            }}
          />
        </div>

        {/* 温馨提示 */}
        <div style={{
          padding: '16px',
          background: '#fff9e6',
          borderRadius: '12px',
          border: '1px solid #ffe58f',
          boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
        }}>
          <h4 style={{ margin: '0 0 12px 0', fontSize: '15px', color: '#d48806', display: 'flex', alignItems: 'center' }}>
            <span style={{ marginRight: '8px' }}>💡</span>
            温馨提示
          </h4>
          <ul style={{ margin: 0, paddingLeft: '20px', fontSize: '13px', color: '#8c6d1f', lineHeight: '1.8' }}>
            <li>请提前10分钟到店���避免迟到影响服务</li>
            <li>如需取消预约，请提前2小时操作</li>
            <li>请保持手机畅通，方便店铺联系</li>
            <li>到店时请向工作人员出示预约码</li>
          </ul>
        </div>
      </div>

      {/* 底部操作按钮 */}
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
        <div style={{ display: 'flex', gap: '12px' }}>
          <Button
            block
            onClick={handleGoBack}
            style={{
              height: '48px',
              fontSize: '16px',
              fontWeight: 'bold',
              flex: 1,
              background: 'white',
              color: '#667eea',
              border: '2px solid #667eea'
            }}
          >
            返回修改
          </Button>
          <Button
            block
            type="primary"
            loading={isSubmitting}
            onClick={handleConfirmBooking}
            style={{
              height: '48px',
              fontSize: '16px',
              fontWeight: 'bold',
              flex: 2,
              background: '#667eea',
              border: 'none'
            }}
          >
            {isSubmitting ? '提交中...' : '确认预约'}
          </Button>
        </div>
      </div>
    </div>
  )
}

export default ConfirmBookingPage
