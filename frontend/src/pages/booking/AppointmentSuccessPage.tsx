import React from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from 'react-vant'
import { Success } from '@react-vant/icons'

const AppointmentSuccessPage: React.FC = () => {
  const navigate = useNavigate()

  return (
    <div style={{ padding: '40px 20px', textAlign: 'center' }}>
      <Success style={{ fontSize: '64px', color: '#07c160' }} />
      <h2 style={{ marginTop: '20px' }}>预约成功！</h2>
      <p style={{ color: '#999', marginTop: '10px' }}>请按时到店服务</p>

      <div style={{ marginTop: '40px', display: 'flex', gap: '12px' }}>
        <Button block onClick={() => navigate('/appointments')}>
          查看我的预约
        </Button>
        <Button type="primary" block onClick={() => navigate('/home')}>
          返回首页
        </Button>
      </div>
    </div>
  )
}

export default AppointmentSuccessPage