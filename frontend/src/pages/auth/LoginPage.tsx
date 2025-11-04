import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Toast, Field, Divider } from 'react-vant'
import { useAppDispatch } from '@/store'
import { loginAsync } from '@/store/slices/authSlice'
import { theme, commonStyles } from '@/styles/theme'

const LoginPage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const [phone, setPhone] = useState('')
  const [code, setCode] = useState('')
  const [loading, setLoading] = useState(false)
  const [countdown, setCountdown] = useState(0)
  const [step, setStep] = useState<'phone' | 'code'>('phone')

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000)
      return () => clearTimeout(timer)
    }
  }, [countdown])

  const handleSendCode = async () => {
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      Toast.info('请输入正确的手机号')
      return
    }

    // 模拟发送验证码
    Toast.info('验证码已发送')
    setCountdown(60)
    setStep('code')
  }

  const handleLogin = async () => {
    if (!code || code.length < 4) {
      Toast.info('请输入验证码')
      return
    }

    setLoading(true)
    try {
      await dispatch(loginAsync({ phone })).unwrap()
      Toast.info('登录成功')
      navigate('/home')
    } catch (error: any) {
      Toast.info(error.message || '登录失败')
    } finally {
      setLoading(false)
    }
  }

  const handleQuickLogin = async () => {
    // 快速登录（开发环境）
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      Toast.info('请输入正确的手机号')
      return
    }

    setLoading(true)
    try {
      await dispatch(loginAsync({ phone })).unwrap()
      Toast.info('登录成功')
      navigate('/home')
    } catch (error: any) {
      Toast.info(error.message || '登录失败')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: `linear-gradient(180deg, ${theme.colors.primary} 0%, ${theme.colors.primaryLight} 50%, ${theme.colors.bgSecondary} 100%)`,
      position: 'relative',
      overflow: 'hidden'
    }}>
      {/* 装饰性背景元素 */}
      <div style={{
        position: 'absolute',
        top: '-50px',
        right: '-50px',
        width: '200px',
        height: '200px',
        borderRadius: theme.borderRadius.round,
        background: 'rgba(255, 255, 255, 0.1)',
        filter: 'blur(60px)'
      }} />
      <div style={{
        position: 'absolute',
        bottom: '100px',
        left: '-100px',
        width: '300px',
        height: '300px',
        borderRadius: theme.borderRadius.round,
        background: 'rgba(255, 255, 255, 0.1)',
        filter: 'blur(80px)'
      }} />

      <div style={{
        position: 'relative',
        zIndex: 1,
        padding: '60px 20px 40px',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column'
      }}>
        {/* Logo 和标题 */}
        <div style={{ textAlign: 'center', marginBottom: theme.spacing.xxl }}>
          <div style={{
            width: '80px',
            height: '80px',
            margin: `0 auto ${theme.spacing.lg}`,
            background: theme.colors.bgPrimary,
            borderRadius: theme.borderRadius.large,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '40px',
            boxShadow: theme.shadows.primary
          }}>
            💇
          </div>
          <h1 style={{
            fontSize: theme.fontSize.huge,
            fontWeight: 'bold',
            color: theme.colors.bgPrimary,
            marginBottom: theme.spacing.sm,
            textShadow: '0 2px 8px rgba(0, 0, 0, 0.1)'
          }}>
            理发店预约
          </h1>
          <p style={{
            color: 'rgba(255, 255, 255, 0.9)',
            fontSize: theme.fontSize.md
          }}>
            便捷预约，无需等待
          </p>
        </div>

        {/* 登录卡片 */}
        <div style={{
          background: theme.colors.bgPrimary,
          borderRadius: `${theme.borderRadius.xxl} ${theme.borderRadius.xxl} 0 0`,
          padding: `${theme.spacing.xxl} ${theme.spacing.lg}`,
          flex: 1,
          boxShadow: theme.shadows.large
        }}>
          <h2 style={{
            fontSize: theme.fontSize.xxl,
            fontWeight: 'bold',
            color: theme.colors.textPrimary,
            marginBottom: theme.spacing.xxl
          }}>
            {step === 'phone' ? '手机号登录' : '输入验证码'}
          </h2>

          {/* 手机号输入 */}
          <div style={{ marginBottom: theme.spacing.md }}>
            <div style={{
              display: 'flex',
              alignItems: 'center',
              background: theme.colors.bgTertiary,
              borderRadius: theme.borderRadius.medium,
              padding: `${theme.spacing.xs} ${theme.spacing.lg}`,
              border: `2px solid ${step === 'phone' ? theme.colors.primary : theme.colors.bgTertiary}`,
              transition: 'all 0.3s ease'
            }}>
              <span style={{
                fontSize: theme.fontSize.lg,
                marginRight: theme.spacing.sm
              }}>
                📱
              </span>
              <Field
                value={phone}
                onChange={setPhone}
                type="tel"
                maxLength={11}
                placeholder="请输入手机号"
                disabled={step === 'code'}
                style={{
                  flex: 1,
                  border: 'none',
                  background: 'transparent',
                  fontSize: theme.fontSize.lg,
                  padding: `${theme.spacing.md} 0`
                }}
              />
              {step === 'code' && (
                <button
                  onClick={() => {
                    setStep('phone')
                    setCode('')
                  }}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: theme.colors.primary,
                    fontSize: theme.fontSize.sm,
                    cursor: 'pointer',
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`
                  }}
                >
                  修改
                </button>
              )}
            </div>
          </div>

          {/* 验证码输入 */}
          {step === 'code' && (
            <div style={{ marginBottom: theme.spacing.xxl, animation: 'slideIn 0.3s' }}>
              <div style={{
                display: 'flex',
                alignItems: 'center',
                background: theme.colors.bgTertiary,
                borderRadius: theme.borderRadius.medium,
                padding: `${theme.spacing.xs} ${theme.spacing.lg}`,
                border: `2px solid ${theme.colors.primary}`
              }}>
                <span style={{
                  fontSize: theme.fontSize.lg,
                  marginRight: theme.spacing.sm
                }}>
                  🔒
                </span>
                <Field
                  value={code}
                  onChange={setCode}
                  type="number"
                  maxLength={6}
                  placeholder="请输入6位验证码"
                  style={{
                    flex: 1,
                    border: 'none',
                    background: 'transparent',
                    fontSize: theme.fontSize.lg,
                    padding: `${theme.spacing.md} 0`
                  }}
                />
                <button
                  onClick={handleSendCode}
                  disabled={countdown > 0}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: countdown > 0 ? theme.colors.textTertiary : theme.colors.primary,
                    fontSize: theme.fontSize.sm,
                    cursor: countdown > 0 ? 'not-allowed' : 'pointer',
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                    whiteSpace: 'nowrap'
                  }}
                >
                  {countdown > 0 ? `${countdown}s` : '重新发送'}
                </button>
              </div>
              <p style={{
                marginTop: theme.spacing.sm,
                fontSize: theme.fontSize.sm,
                color: theme.colors.textTertiary,
                paddingLeft: theme.spacing.lg
              }}>
                验证码已发送至 {phone}
              </p>
            </div>
          )}

          {/* 操作按钮 */}
          <div style={{ marginTop: theme.spacing.xxl }}>
            {step === 'phone' ? (
              <Button
                type="primary"
                block
                round
                onClick={handleSendCode}
                style={commonStyles.primaryButton}
              >
                获取验证码
              </Button>
            ) : (
              <Button
                type="primary"
                block
                round
                loading={loading}
                onClick={handleLogin}
                disabled={!code || code.length < 4}
                style={{
                  ...commonStyles.primaryButton,
                  opacity: !code || code.length < 4 ? 0.6 : 1,
                  cursor: !code || code.length < 4 ? 'not-allowed' : 'pointer'
                }}
              >
                登录 / 注册
              </Button>
            )}
          </div>

          {/* 快捷登录 (开发环境) */}
          {import.meta.env.MODE === 'development' && (
            <>
              <Divider style={{ margin: '24px 0' }}>开发环境快捷登录</Divider>
              <Button
                block
                onClick={handleQuickLogin}
                style={{
                  height: '44px',
                  fontSize: theme.fontSize.md,
                  background: theme.colors.bgSecondary,
                  color: theme.colors.textSecondary,
                  border: 'none',
                  borderRadius: theme.borderRadius.medium
                }}
              >
                跳过验证码直接登录
              </Button>
            </>
          )}

          {/* 协议提示 */}
          <div style={{
            marginTop: theme.spacing.xxl,
            textAlign: 'center',
            fontSize: theme.fontSize.xs,
            color: theme.colors.textTertiary,
            lineHeight: '1.6'
          }}>
            <p>
              登录即表示同意
              <span style={{ color: theme.colors.primary }}> 用户协议</span> 和
              <span style={{ color: theme.colors.primary }}> 隐私政策</span>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default LoginPage