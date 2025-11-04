import React from 'react'
import { Cell, Button } from 'react-vant'
import { useNavigate } from 'react-router-dom'
import { useAppDispatch, useAppSelector } from '@/store'
import { clearAuth } from '@/store/slices/authSlice'
import { theme } from '@/styles/theme'

const ProfilePage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { user } = useAppSelector(state => state.auth)

  const handleLogout = () => {
    dispatch(clearAuth())
    navigate('/login')
  }

  return (
    <div style={{ background: theme.colors.bgSecondary, minHeight: '100vh', paddingBottom: '60px' }}>
      <div style={{
        background: theme.button.primary.background,
        padding: '40px 20px',
        color: theme.colors.bgPrimary,
        textAlign: 'center'
      }}>
        <div style={{
          width: '80px',
          height: '80px',
          borderRadius: theme.borderRadius.round,
          background: theme.colors.bgPrimary,
          margin: `0 auto ${theme.spacing.md}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '36px'
        }}>
          👤
        </div>
        <h2 style={{ margin: 0, fontSize: theme.fontSize.xxl, fontWeight: 'bold' }}>{user?.nickname || '用户'}</h2>
        <p style={{ margin: `${theme.spacing.sm} 0 0`, opacity: 0.9, fontSize: theme.fontSize.base }}>{user?.phone}</p>
      </div>

      <div style={{ margin: theme.spacing.lg }}>
        <Cell.Group>
         <Cell title="我的预约" isLink onClick={() => navigate('/appointments')} />
        </Cell.Group>

        <Button
          block
          onClick={handleLogout}
          style={{ 
            marginTop: theme.spacing.xl,
            height: '44px',
            fontSize: theme.fontSize.lg,
            fontWeight: 'bold',
            background: theme.colors.bgPrimary,
            color: theme.colors.error,
            border: `2px solid ${theme.colors.error}`,
            borderRadius: theme.borderRadius.medium
          }}
        >
          退出登录
        </Button>
      </div>
    </div>
  )
}

export default ProfilePage