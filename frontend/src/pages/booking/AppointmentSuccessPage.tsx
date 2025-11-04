import React from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from 'react-vant'
import { Success } from '@react-vant/icons'
import { theme, commonStyles } from '@/styles/theme'

const AppointmentSuccessPage: React.FC = () => {
  const navigate = useNavigate()

  return (
    <div style={{ 
      background: theme.colors.bgSecondary,
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      paddingBottom: '100px'
    }}>
      {/* 主要内容区域 - 居中显示 */}
      <div style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: theme.spacing.xxl,
        textAlign: 'center'
      }}>
        {/* 成功图标 */}
        <div style={{
          width: '120px',
          height: '120px',
          borderRadius: theme.borderRadius.round,
          background: theme.colors.primaryLight,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginBottom: theme.spacing.xl
        }}>
          <Success style={{ 
            fontSize: '80px', 
            color: theme.colors.primary 
          }} />
        </div>

        {/* 标题 */}
        <h2 style={{ 
          margin: 0,
          marginBottom: theme.spacing.md,
          fontSize: theme.fontSize.xxl,
          fontWeight: 'bold',
          color: theme.colors.textPrimary
        }}>
          预约成功！
        </h2>

        {/* 副标题 */}
        <p style={{ 
          margin: 0,
          color: theme.colors.textSecondary, 
          fontSize: theme.fontSize.base,
          lineHeight: '1.6'
        }}>
          请按时到店服务
        </p>
      </div>

      {/* 底部按钮区域 */}
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
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          gap: theme.spacing.md
        }}>
          <Button 
            block 
            round
            onClick={() => navigate('/appointments')}
            style={{
              ...commonStyles.primaryButton,
              height: '52px',
              fontSize: theme.fontSize.lg
            }}
          >
            查看我的预约
          </Button>
          <Button 
            block 
            round
            onClick={() => navigate('/home')}
            style={{
              height: '52px',
              fontSize: theme.fontSize.lg,
              fontWeight: 'bold',
              background: theme.colors.bgPrimary,
              color: theme.colors.primary,
              border: `2px solid ${theme.colors.primary}`
            }}
          >
            返回首页
          </Button>
        </div>
      </div>
    </div>
  )
}

export default AppointmentSuccessPage