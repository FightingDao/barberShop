import React from 'react'
import { Outlet, useLocation, useNavigate } from 'react-router-dom'
import { Tabbar } from 'react-vant'
import { HomeO, OrdersO, UserO } from '@react-vant/icons'

const Layout: React.FC = () => {
  const navigate = useNavigate()
  const location = useLocation()

  // 从路径中提取当前激活的tab
  const getActiveTab = () => {
    const path = location.pathname
    if (path.startsWith('/home')) return 'home'
    if (path.startsWith('/appointments')) return 'appointments'
    if (path.startsWith('/profile')) return 'profile'
    return 'home'
  }

  const handleTabChange = (name: string | number) => {
    navigate(`/${name}`)
  }

  // 判断是否显示底部导航栏
  const showTabbar = () => {
    const path = location.pathname
    // 在这些路径隐藏底部导航
    const hiddenPaths = ['/login', '/booking/success']
    return !hiddenPaths.some(p => path.includes(p)) && !path.includes('/booking/')
  }

  return (
    <div className="layout" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'auto' }}>
        <Outlet />
      </div>

      {showTabbar() && (
        <Tabbar
          value={getActiveTab()}
          onChange={handleTabChange}
          fixed
          placeholder
          style={{ height: '50px' }}
        >
          <Tabbar.Item icon={<HomeO />} name="home">
            首页
          </Tabbar.Item>
          <Tabbar.Item icon={<OrdersO />} name="appointments">
            预约
          </Tabbar.Item>
          <Tabbar.Item icon={<UserO />} name="profile">
            我的
          </Tabbar.Item>
        </Tabbar>
      )}
    </div>
  )
}

export default Layout