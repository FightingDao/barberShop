import React, { useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Button, Loading, NavBar } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopDetailAsync } from '@/store/slices/shopsSlice'
import { setShop } from '@/store/slices/bookingSlice'

const ShopDetailPage: React.FC = () => {
  const { id } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { currentShop, isLoading } = useAppSelector(state => state.shops)

  useEffect(() => {
    if (id) {
      dispatch(fetchShopDetailAsync(Number(id)))
    }
  }, [id, dispatch])

  const handleBooking = () => {
    if (currentShop) {
      dispatch(setShop(currentShop))
      navigate(`/booking/select-service/${currentShop.id}`)
    }
  }

  if (isLoading || !currentShop) {
    return <Loading size="24px" style={{ marginTop: '100px' }} />
  }

  return (
    <div>
      <NavBar title="店铺详情" onClickLeft={() => navigate(-1)} />

      <div style={{ padding: '16px' }}>
        <h2>{currentShop.name}</h2>
        <p>📍 {currentShop.address}</p>
        <p>{currentShop.description}</p>

        <Button
          type="primary"
          block
          round
          onClick={handleBooking}
          style={{ marginTop: '20px' }}
        >
          立即预约
        </Button>
      </div>
    </div>
  )
}

export default ShopDetailPage