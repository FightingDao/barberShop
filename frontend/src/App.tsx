import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Provider } from 'react-redux'
import { ConfigProvider } from 'react-vant'

import store from './store'
import Layout from './components/common/Layout'
import HomePage from './pages/shops/HomePage'
import ShopDetailPage from './pages/shops/ShopDetailPage'
import BookingFlow from './pages/booking/BookingFlow'
import SelectServicePage from './pages/booking/SelectServicePage'
import SelectStylistPage from './pages/booking/SelectStylistPage'
import SelectTimePage from './pages/booking/SelectTimePage'
import ConfirmBookingPage from './pages/booking/ConfirmBookingPage'
import AppointmentSuccessPage from './pages/booking/AppointmentSuccessPage'
import ProfilePage from './pages/profile/ProfilePage'
import AppointmentsPage from './pages/profile/AppointmentsPage'
import AppointmentDetailPage from './pages/profile/AppointmentDetailPage'
import LoginPage from './pages/auth/LoginPage'
import ProtectedRoute from './components/common/ProtectedRoute'

// 启用桌面端触摸模拟（开发环境）
if (typeof window !== 'undefined') {
  import('@vant/touch-emulator').then(module => {
    module.TouchEmulator()
  }).catch(() => {
    // 忽略错误
  })
}

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <ConfigProvider>
        <Router>
          <div className="App">
            <Routes>
              {/* 公开路由 */}
              <Route path="/login" element={<LoginPage />} />

              {/* 主要应用路由 */}
              <Route path="/" element={<Layout />}>
                <Route index element={<Navigate to="/home" replace />} />
                <Route path="home" element={<HomePage />} />
                <Route path="shops/:id" element={<ShopDetailPage />} />
                <Route path="booking" element={<BookingFlow />}>
                  <Route path="select-service/:shopId" element={<ProtectedRoute><SelectServicePage /></ProtectedRoute>} />
                  <Route path="select-stylist/:shopId" element={<ProtectedRoute><SelectStylistPage /></ProtectedRoute>} />
                  <Route path="select-time/:shopId" element={<ProtectedRoute><SelectTimePage /></ProtectedRoute>} />
                  <Route path="confirm/:shopId" element={<ProtectedRoute><ConfirmBookingPage /></ProtectedRoute>} />
                </Route>
                <Route path="booking/success" element={<AppointmentSuccessPage />} />
                <Route path="profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />
                <Route path="appointments" element={<ProtectedRoute><AppointmentsPage /></ProtectedRoute>} />
                <Route path="appointments/:id" element={<ProtectedRoute><AppointmentDetailPage /></ProtectedRoute>} />
              </Route>

              {/* 404 页面 */}
              <Route path="*" element={<Navigate to="/home" replace />} />
            </Routes>
          </div>
        </Router>
      </ConfigProvider>
    </Provider>
  )
}

export default App
