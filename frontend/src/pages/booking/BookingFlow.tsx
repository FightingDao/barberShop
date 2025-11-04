import React from 'react'
import { Outlet } from 'react-router-dom'

const BookingFlow: React.FC = () => {
  return (
    <div>
      <Outlet />
    </div>
  )
}

export default BookingFlow