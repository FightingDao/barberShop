import React, { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { NavBar, Button, Field, Dialog, Notify } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { setNotes, resetBookingFlow } from '@/store/slices/bookingSlice'
import { bookingApi } from '@/services'
import { theme, commonStyles } from '@/styles/theme'

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
    <div style={{
      background: theme.colors.bgSecondary,
      minHeight: '100vh',
      paddingBottom: '100px'
    }}>
      {/* 顶部导航 */}
      <NavBar
        title="确认预约"
        onClickLeft={handleGoBack}
        style={{
          background: theme.colors.bgPrimary,
          boxShadow: theme.shadows.small
        }}
      />

      <div style={{ padding: theme.spacing.lg }}>
        {/* 预约信息确认 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg
        }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.lg} 0`,
            fontSize: theme.fontSize.xl,
            color: theme.colors.textPrimary,
            borderBottom: `2px solid ${theme.colors.primary}`,
            paddingBottom: theme.spacing.md,
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: theme.spacing.sm }}>📋</span>
            预约信息
          </h3>

          <div style={{ lineHeight: '2.4' }}>
            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              background: theme.colors.bgTertiary,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`,
              borderRadius: theme.borderRadius.small
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                店铺名称
              </span>
              <span style={{
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                {shop?.name}
              </span>
            </div>

            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                店铺地址
              </span>
              <span style={{
                fontSize: theme.fontSize.sm,
                color: theme.colors.textSecondary
              }}>
                {shop?.address}
              </span>
            </div>

            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              background: theme.colors.bgTertiary,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`,
              borderRadius: theme.borderRadius.small
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                服务项目
              </span>
              <span style={{
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                {service?.name}
              </span>
            </div>

            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                理发师
              </span>
              <span style={{
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                {stylist?.name || '不指定'}
              </span>
            </div>

            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              background: theme.colors.bgTertiary,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`,
              borderRadius: theme.borderRadius.small
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                预约时间
              </span>
              <div style={{ flex: 1 }}>
                <div style={{
                  fontWeight: 'bold',
                  color: theme.colors.textPrimary,
                  marginBottom: theme.spacing.xs
                }}>
                  {formatDate(selectedDate)}
                </div>
                <div style={{
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.primary,
                  fontWeight: 'bold'
                }}>
                  {timeSlot?.startTime?.substring(0, 5)}
                </div>
              </div>
            </div>

            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                服务时长
              </span>
              <span style={{ color: theme.colors.textSecondary }}>
                {service?.duration}分钟
              </span>
            </div>

            <div style={{
              display: 'flex',
              alignItems: 'center',
              background: theme.colors.primaryLight,
              padding: theme.spacing.md,
              borderRadius: theme.borderRadius.small,
              border: `1px solid ${theme.colors.primary}`
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                服务价格
              </span>
              <span style={{
                fontSize: theme.fontSize.huge,
                fontWeight: 'bold',
                color: theme.colors.primary
              }}>
                ¥{service?.price}
              </span>
            </div>
          </div>
        </div>

        {/* 联系信息 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg
        }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.lg} 0`,
            fontSize: theme.fontSize.xl,
            color: theme.colors.textPrimary,
            borderBottom: `2px solid ${theme.colors.primary}`,
            paddingBottom: theme.spacing.md,
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: theme.spacing.sm }}>👤</span>
            联系信息
          </h3>

          <div style={{ lineHeight: '2.4' }}>
            <div style={{
              display: 'flex',
              marginBottom: theme.spacing.md,
              background: theme.colors.bgTertiary,
              padding: `${theme.spacing.sm} ${theme.spacing.md}`,
              borderRadius: theme.borderRadius.small
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                姓名
              </span>
              <span style={{
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                {user?.nickname || '用户'}
              </span>
            </div>

            <div style={{
              display: 'flex',
              padding: `${theme.spacing.sm} ${theme.spacing.md}`
            }}>
              <span style={{
                color: theme.colors.textTertiary,
                width: '90px',
                flexShrink: 0
              }}>
                手机号
              </span>
              <span style={{
                fontWeight: 'bold',
                color: theme.colors.textPrimary
              }}>
                {user?.phone}
              </span>
            </div>
          </div>
        </div>

        {/* 备注 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg
        }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.xl,
            color: theme.colors.textPrimary,
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: theme.spacing.sm }}>📝</span>
            备注信息
            <span style={{
              fontSize: theme.fontSize.sm,
              color: theme.colors.textTertiary,
              fontWeight: 'normal',
              marginLeft: theme.spacing.sm
            }}>
              (可选)
            </span>
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
              background: theme.colors.bgTertiary,
              borderRadius: theme.borderRadius.small,
              padding: theme.spacing.md
            }}
          />
        </div>

        {/* 温馨提示 */}
        <div style={{
          padding: theme.spacing.lg,
          background: theme.colors.warning + '20',
          borderRadius: theme.borderRadius.medium,
          border: `1px solid ${theme.colors.warning}`,
          boxShadow: theme.shadows.small
        }}>
          <h4 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.md,
            color: theme.colors.warning,
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ marginRight: theme.spacing.sm }}>💡</span>
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
        padding: theme.spacing.lg,
        background: theme.colors.bgPrimary,
        borderTop: `1px solid ${theme.colors.borderLight}`,
        boxShadow: theme.shadows.large
      }}>
        <div style={{ display: 'flex', gap: theme.spacing.md }}>
          <Button
            block
            round
            onClick={handleGoBack}
            style={{
              height: '52px',
              fontSize: theme.fontSize.lg,
              fontWeight: 'bold',
              flex: 1,
              background: theme.colors.bgPrimary,
              color: theme.colors.primary,
              border: `2px solid ${theme.colors.primary}`
            }}
          >
            返回修改
          </Button>
          <Button
            block
            round
            type="primary"
            loading={isSubmitting}
            onClick={handleConfirmBooking}
            style={{
              height: '52px',
              fontSize: theme.fontSize.lg,
              fontWeight: 'bold',
              flex: 2,
              ...commonStyles.primaryButton
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
