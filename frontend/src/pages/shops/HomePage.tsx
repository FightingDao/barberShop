import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Card, Loading, Empty, Search } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopsAsync } from '@/store/slices/shopsSlice'

const HomePage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shops, isLoading } = useAppSelector(state => state.shops)

  useEffect(() => {
    dispatch(fetchShopsAsync())
  }, [dispatch])

  if (isLoading) {
    return (
      <div style={{ padding: '100px 0', textAlign: 'center' }}>
        <Loading size="24px" />
      </div>
    )
  }

  return (
    <div style={{ background: '#f8f9fa', minHeight: '100vh', paddingBottom: '60px' }}>
      {/* Header */}
      <div style={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        padding: '20px',
        color: 'white'
      }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: '0 0 16px 0' }}>
          💇 理发店预约
        </h1>
        <Search
          placeholder="搜索理发店"
          shape="round"
          background="transparent"
          style={{ padding: 0 }}
        />
      </div>

      {/* Shop List */}
      <div style={{ padding: '16px' }}>
        {shops.length === 0 ? (
          <Empty description="暂无店铺" />
        ) : (
          shops.map(shop => (
            <Card
              key={shop.id}
              onClick={() => navigate(`/shops/${shop.id}`)}
              style={{ marginBottom: '12px', cursor: 'pointer' }}
            >
              <div style={{ display: 'flex', gap: '12px' }}>
                <div style={{
                  width: '80px',
                  height: '80px',
                  borderRadius: '8px',
                  background: '#e0e0e0',
                  flexShrink: 0
                }}>
                  {shop.avatarUrl && (
                    <img
                      src={shop.avatarUrl}
                      alt={shop.name}
                      style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: '8px' }}
                    />
                  )}
                </div>
                <div style={{ flex: 1 }}>
                  <h3 style={{ margin: '0 0 8px 0', fontSize: '16px', fontWeight: 'bold' }}>
                    {shop.name}
                  </h3>
                  <p style={{ margin: '0 0 4px 0', fontSize: '14px', color: '#666' }}>
                    📍 {shop.address}
                  </p>
                  <p style={{ margin: 0, fontSize: '12px', color: '#999' }}>
                    营业时间: {new Date(shop.openingTime).toLocaleTimeString('zh-CN', {hour: '2-digit', minute: '2-digit'})} - {new Date(shop.closingTime).toLocaleTimeString('zh-CN', {hour: '2-digit', minute: '2-digit'})}
                  </p>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  )
}

export default HomePage