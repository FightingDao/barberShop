import React, { useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Card, Button, NavBar, Loading, Dialog, Toast } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchAppointmentDetailAsync, cancelAppointmentAsync } from '@/store/slices/appointmentsSlice'

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
    <div>
      <NavBar title="预约详情" onClickLeft={() => navigate(-1)} />

      <div style={{ padding: '16px' }}>
        <Card>
          <div style={{ marginBottom: '12px' }}>
            <h3 style={{ margin: '0 0 16px 0', fontSize: '18px' }}>预约信息</h3>
            <div style={{ lineHeight: '2' }}>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>预约码:</span>
                <span style={{ fontWeight: 'bold', color: '#667eea' }}>{currentAppointment.confirmationCode}</span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>店铺:</span>
                <span>{currentAppointment.shop?.name}</span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>服务:</span>
                <span>{currentAppointment.service?.name}</span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>理发师:</span>
                <span>{currentAppointment.stylist?.name || '不指定'}</span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>预约时间:</span>
                <span>
                  {new Date(currentAppointment.appointmentDate).toLocaleDateString('zh-CN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                  })}{' '}
                  {currentAppointment.appointmentTime}
                </span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>服务时长:</span>
                <span>{currentAppointment.service?.duration || 0}分钟</span>
              </div>
              <div style={{ display: 'flex', marginBottom: '8px' }}>
                <span style={{ color: '#999', width: '80px' }}>服务价格:</span>
                <span style={{ color: '#ff6b6b', fontWeight: 'bold' }}>¥{currentAppointment.service?.price || 0}</span>
              </div>
              <div style={{ display: 'flex' }}>
                <span style={{ color: '#999', width: '80px' }}>状态:</span>
                <span style={{
                  color: currentAppointment.status === 'pending' ? '#07c160' :
                         currentAppointment.status === 'cancelled' ? '#ff6b6b' : '#999',
                  fontWeight: 'bold'
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
            style={{ marginTop: '20px' }}
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