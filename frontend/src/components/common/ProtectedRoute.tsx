import React from 'react'
import { Navigate } from 'react-router-dom'
import { useAppSelector } from '@/store'

interface ProtectedRouteProps {
  children: React.ReactNode
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated } = useAppSelector(state => state.auth)

  if (!isAuthenticated) {
    // 未登录，重定向到登录页
    return <Navigate to="/login" replace />
  }

  return <>{children}</>
}

export default ProtectedRoute