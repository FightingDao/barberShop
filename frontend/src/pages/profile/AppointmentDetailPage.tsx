import React, { useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Card, Button, Loading, Dialog, Toast } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchAppointmentDetailAsync, cancelAppointmentAsync } from '@/store/slices/appointmentsSlice'
import { theme } from '@/styles/theme'

const AppointmentDetailPage: React.FC = () => {
  const { id } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { currentAppointment, isLoading } = useAppSelector(state => state.appointments)

  useEffect(() => {
    if (id) {
      dispatch(fetchAppointmentDetailAsync(Number(id)))
    }
  }, [id, dispatch])

  const handleCancelAppointment = async () => {
    const result = await Dialog.confirm({
      title: '确认取消',
      message: '确定要取消这个预约吗？',
      confirmButtonColor: theme.colors.primary,
    })

    if (result) {
      try {
        await dispatch(cancelAppointmentAsync(Number(id))).unwrap()
        Toast.info('预约已取消')
        navigate('/appointments')
      } catch (error) {
        Toast.info((error as Error).message || '取消预约失败')
      }
    }
  }

  if (isLoading || !currentAppointment) {
    return <Loading size="24px" style={{ marginTop: '100px' }} />
  }

  const getStatusText = (status: string) => {
    const statusMap: Record<string, string> = {
      pending: '待服务',
      completed: '已完成',
      cancelled: '已取消',
      no_show: '未到店',
    }
    return statusMap[status] || status
  }

  return (
    <div style={{ background: theme.colors.bgSecondary, minHeight: '100vh' }}>
      {/* 自定义顶部导航 - 固定在顶部 */}
      <div style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 100,
        background: theme.colors.bgPrimary,
        boxShadow: theme.shadows.small,
        padding: `${theme.spacing.md} ${theme.spacing.lg}`,
        display: 'flex',
        alignItems: 'center'
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
          预约详情
        </h2>
      </div>

      <div style={{ 
        padding: theme.spacing.lg,
        paddingTop: '60px' // 为固定的topbar留出空间
      }}>
        <Card
          style={{
            borderRadius: theme.borderRadius.large,
            boxShadow: theme.shadows.medium,
            border: 'none',
            overflow: 'hidden',
            background: theme.colors.bgPrimary,
            padding: theme.spacing.xl
          }}
        >
          <div style={{ marginBottom: theme.spacing.lg }}>
            <h3 style={{ 
              margin: `0 0 ${theme.spacing.xl} 0`, 
              fontSize: theme.fontSize.xl,
              fontWeight: 'bold',
              color: theme.colors.textPrimary
            }}>预约信息</h3>
            <div style={{ lineHeight: 2 }}>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>预约码:</span>
                <span style={{ 
                  fontWeight: 'bold', 
                  color: theme.colors.primary,
                  fontSize: theme.fontSize.base 
                }}>{currentAppointment.confirmationCode}</span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>店铺:</span>
                <span style={{ 
                  color: theme.colors.textPrimary,
                  fontSize: theme.fontSize.base,
                  fontWeight: 'bold'
                }}>{currentAppointment.shop?.name}</span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>服务:</span>
                <span style={{ 
                  color: theme.colors.textPrimary,
                  fontSize: theme.fontSize.base 
                }}>{currentAppointment.service?.name}</span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>理发师:</span>
                <span style={{ 
                  color: theme.colors.textPrimary,
                  fontSize: theme.fontSize.base 
                }}>{currentAppointment.stylist?.name || '不指定'}</span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>预约时间:</span>
                <span style={{ 
                  color: theme.colors.textPrimary,
                  fontSize: theme.fontSize.base 
                }}>
                  {new Date(currentAppointment.appointmentDate).toLocaleDateString('zh-CN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                  })}{' '}
                  {currentAppointment.appointmentTime}
                </span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>服务时长:</span>
                <span style={{ 
                  color: theme.colors.textPrimary,
                  fontSize: theme.fontSize.base 
                }}>{currentAppointment.service?.durationMinutes || currentAppointment.durationMinutes || 0}分钟</span>
              </div>
              <div style={{ 
                display: 'flex', 
                marginBottom: theme.spacing.md,
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>服务价格:</span>
                <span style={{ 
                  color: theme.colors.primary, 
                  fontWeight: 'bold',
                  fontSize: theme.fontSize.lg 
                }}>¥{currentAppointment.service?.price || 0}</span>
              </div>
              <div style={{ 
                display: 'flex',
                alignItems: 'center'  
              }}>
                <span style={{ 
                  color: theme.colors.textTertiary, 
                  width: '80px',
                  fontSize: theme.fontSize.base 
                }}>状态:</span>
                <span style={{
                  color: currentAppointment.status === 'pending' ? theme.colors.primary :
                         currentAppointment.status === 'cancelled' ? theme.colors.error : theme.colors.success,
                  fontWeight: 'bold',
                  fontSize: theme.fontSize.base
                }}>
                  {getStatusText(currentAppointment.status)}
                </span>
              </div>
            </div>
          </div>
        </Card>

        {currentAppointment.status === 'pending' && (
          <Button
            block
            type="danger"
            style={{ 
              marginTop: theme.spacing.xl,
              height: '44px',
              fontSize: theme.fontSize.lg,
              fontWeight: 'bold',
              borderRadius: theme.borderRadius.medium
            }}
            onClick={handleCancelAppointment}
          >
            取消预约
          </Button>
        )}
      </div>
    </div>
  )
}

export default AppointmentDetailPage