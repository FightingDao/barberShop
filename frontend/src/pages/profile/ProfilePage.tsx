import React from 'react'
import { Cell, Button } from 'react-vant'
import { useNavigate } from 'react-router-dom'
import { useAppDispatch, useAppSelector } from '@/store'
import { clearAuth } from '@/store/slices/authSlice'

const ProfilePage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { user } = useAppSelector(state => state.auth)

  const handleLogout = () => {
    dispatch(clearAuth())
    navigate('/login')
  }

  return (
    <div style={{ background: '#f8f9fa', minHeight: '100vh', paddingBottom: '60px' }}>
      <div style={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        padding: '40px 20px',
        color: 'white',
        textAlign: 'center'
      }}>
        <div style={{
          width: '80px',
          height: '80px',
          borderRadius: '50%',
          background: 'white',
          margin: '0 auto 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '36px'
        }}>
          👤
        </div>
        <h2 style={{ margin: 0 }}>{user?.nickname || '用户'}</h2>
        <p style={{ margin: '8px 0 0', opacity: 0.8 }}>{user?.phone}</p>
      </div>

      <div style={{ margin: '16px' }}>
        <Cell.Group>
          <Cell title="我的预约" isLink onClick={() => navigate('/appointments')} />
          <Cell title="个人信息" isLink />
          <Cell title="设置" isLink />
        </Cell.Group>

        <Button
          block
          type="danger"
          onClick={handleLogout}
          style={{ marginTop: '24px' }}
        >
          退出登录
        </Button>
      </div>
    </div>
  )
}

export default ProfilePage