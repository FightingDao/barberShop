import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Form, Button, Toast } from 'react-vant'
import { useAppDispatch } from '@/store'
import { loginAsync } from '@/store/slices/authSlice'

const LoginPage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const [phone, setPhone] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = async () => {
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
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px'
    }}>
      <div style={{
        background: 'white',
        borderRadius: '16px',
        padding: '40px 24px',
        width: '100%',
        maxWidth: '400px',
        boxShadow: '0 10px 40px rgba(0,0,0,0.1)'
      }}>
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <h1 style={{
            fontSize: '32px',
            fontWeight: 'bold',
            color: '#333',
            marginBottom: '8px'
          }}>
            💇 理发店预约
          </h1>
          <p style={{ color: '#999', fontSize: '14px' }}>欢迎使用，请登录继续</p>
        </div>

        <Form>
          <Form.Item
            label="手机号"
            rules={[{ required: true, message: '请输入手机号' }]}
          >
            <input
              type="tel"
              placeholder="请输入手机号"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              maxLength={11}
              style={{
                width: '100%',
                padding: '12px',
                fontSize: '16px',
                border: '1px solid #e0e0e0',
                borderRadius: '8px',
                outline: 'none'
              }}
            />
          </Form.Item>

          <div style={{ marginTop: '24px' }}>
            <Button
              type="primary"
              block
              round
              loading={loading}
              onClick={handleLogin}
              style={{
                height: '48px',
                fontSize: '16px',
                fontWeight: '500'
              }}
            >
              登录 / 注册
            </Button>
          </div>
        </Form>

        <div style={{
          marginTop: '24px',
          textAlign: 'center',
          color: '#999',
          fontSize: '12px'
        }}>
          <p>登录即表示同意用户协议和隐私政策</p>
          <p style={{ marginTop: '8px', color: '#FF6B6B' }}>
            开发环境：直接输入手机号即可登录
          </p>
        </div>
      </div>
    </div>
  )
}

export default LoginPage