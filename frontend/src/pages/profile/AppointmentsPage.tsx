import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Tabs, Card, Empty, Loading, NavBar } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchAppointmentsAsync } from '@/store/slices/appointmentsSlice'

const AppointmentsPage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { pendingAppointments, completedAppointments, isLoading } = useAppSelector(
    state => state.appointments
  )

  useEffect(() => {
    dispatch(fetchAppointmentsAsync())
  }, [dispatch])

  if (isLoading) {
    return <Loading size="24px" style={{ marginTop: '100px' }} />
  }

  return (
    <div>
      <NavBar title="我的预约" onClickLeft={() => navigate(-1)} />

      <Tabs>
        <Tabs.TabPane title="待服务" key="pending">
          <div style={{ padding: '16px' }}>
            {pendingAppointments.length === 0 ? (
              <Empty description="暂无预约" />
            ) : (
              pendingAppointments.map(apt => (
                <Card
                  key={apt.id}
                  onClick={() => navigate(`/appointments/${apt.id}`)}
                  style={{ marginBottom: '12px' }}
                >
                  <h4>{apt.shop?.name}</h4>
                  <p>服务: {apt.service?.name}</p>
                  <p>理发师: {apt.stylist?.name || '不指定'}</p>
                  <p>时间: {new Date(apt.appointmentDate).toLocaleDateString()} {new Date(apt.appointmentTime).toLocaleTimeString()}</p>
                </Card>
              ))
            )}
          </div>
        </Tabs.TabPane>

        <Tabs.TabPane title="已完成" key="completed">
          <div style={{ padding: '16px' }}>
            {completedAppointments.length === 0 ? (
              <Empty description="暂无记录" />
            ) : (
              completedAppointments.map(apt => (
                <Card
                  key={apt.id}
                  style={{ marginBottom: '12px', opacity: 0.7 }}
                >
                  <h4>{apt.shop?.name}</h4>
                  <p>服务: {apt.service?.name}</p>
                  <p>时间: {new Date(apt.appointmentDate).toLocaleDateString()}</p>
                </Card>
              ))
            )}
          </div>
        </Tabs.TabPane>
      </Tabs>
    </div>
  )
}

export default AppointmentsPage