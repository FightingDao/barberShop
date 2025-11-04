import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Card, Loading, Empty, Search } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopsAsync } from '@/store/slices/shopsSlice'
import { theme, commonStyles } from '@/styles/theme'
import shopImg from '@/assets/shop.jpeg'

const HomePage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shops, isLoading } = useAppSelector(state => state.shops)

  useEffect(() => {
    dispatch(fetchShopsAsync())
  }, [dispatch])

  if (isLoading) {
    return (
      <div style={commonStyles.loadingCenter}>
        <Loading size="24px" color={theme.colors.primary} />
      </div>
    )
  }

  return (
    <div style={commonStyles.container}>
      {/* Header */}
      <div style={{
        background: theme.colors.bgPrimary,
        padding: `${theme.spacing.lg} ${theme.spacing.lg} ${theme.spacing.md}`,
        boxShadow: theme.shadows.small,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: theme.spacing.lg
      }}>
        <h1 style={{
          fontSize: theme.fontSize.xxl,
          fontWeight: 'bold',
          margin: 0,
          color: theme.colors.textPrimary
        }}>
          附近理发店
        </h1>
        <div style={{
          width: '40px',
          height: '40px',
          borderRadius: theme.borderRadius.round,
          background: theme.colors.primaryLight,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer'
        }}>
          <span style={{ fontSize: '20px' }}>👤</span>
        </div>
      </div>

      {/* Search Bar */}
      <div style={{
        padding: `0 ${theme.spacing.lg} ${theme.spacing.lg}`,
        marginBottom: theme.spacing.lg
      }}>
        <Search
          placeholder="搜索理发店"
          shape="round"
          background={theme.colors.bgPrimary}
          style={{
            padding: 0,
            boxShadow: theme.shadows.small,
            borderRadius: theme.borderRadius.large
          }}
        />
      </div>

      {/* Shop List */}
      <div style={{ padding: `0 ${theme.spacing.lg}` }}>
        {shops.length === 0 ? (
          <div style={commonStyles.empty}>
            <Empty description="暂无店铺" />
          </div>
        ) : (
          shops.map(shop => (
            <Card
              key={shop.id}
              onClick={() => navigate(`/shops/${shop.id}`)}
              style={{
                marginBottom: theme.spacing.lg,
                cursor: 'pointer',
                borderRadius: theme.borderRadius.medium,
                boxShadow: theme.shadows.small,
                padding: 0,
                overflow: 'hidden'
              }}
            >
              {/* 店铺大图 */}
              <div style={{
                width: '100%',
                height: '180px',
                background: '#e0e0e0',
                position: 'relative'
              }}>
                {shop.avatarUrl ? (
                  <img
                    src={shopImg}
                    alt={shop.name}
                    style={{
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover'
                    }}
                  />
                ) : (
                  <div style={{
                    width: '100%',
                    height: '100%',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    background: theme.colors.bgTertiary,
                    color: theme.colors.textTertiary
                  }}>
                    <span style={{ fontSize: '48px' }}>💈</span>
                  </div>
                )}

                {/* 营业状态标签 */}
                <div style={{
                  position: 'absolute',
                  top: theme.spacing.md,
                  left: theme.spacing.md,
                  background: theme.colors.primary,
                  color: theme.colors.bgPrimary,
                  padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                  borderRadius: theme.borderRadius.small,
                  fontSize: theme.fontSize.sm,
                  fontWeight: 'bold'
                }}>
                  营业中
                </div>

                {/* 收藏按钮 */}
                <div style={{
                  position: 'absolute',
                  top: theme.spacing.md,
                  right: theme.spacing.md,
                  width: '36px',
                  height: '36px',
                  background: theme.colors.bgPrimary,
                  borderRadius: theme.borderRadius.round,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  boxShadow: theme.shadows.medium
                }}>
                  <span style={{ fontSize: '18px', color: theme.colors.textTertiary }}>🤍</span>
                </div>
              </div>

              {/* 店铺信息 */}
              <div style={{ padding: theme.spacing.lg }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginBottom: theme.spacing.sm
                }}>
                  <h3 style={{
                    margin: 0,
                    fontSize: theme.fontSize.lg,
                    fontWeight: 'bold',
                    color: theme.colors.textPrimary
                  }}>
                    {shop.name}
                  </h3>
                  <div style={{ display: 'flex', alignItems: 'center' }}>
                    <span style={{
                      color: theme.colors.star,
                      fontSize: theme.fontSize.sm,
                      marginRight: theme.spacing.xs
                    }}>
                      ⭐
                    </span>
                    <span style={{
                      fontSize: theme.fontSize.sm,
                      color: theme.colors.textSecondary,
                      fontWeight: 'bold'
                    }}>
                      4.8
                    </span>
                  </div>
                </div>

                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: theme.spacing.md,
                  marginBottom: theme.spacing.sm
                }}>
                  <span style={{
                    fontSize: theme.fontSize.sm,
                    color: theme.colors.textSecondary
                  }}>
                    人均 ¥{Math.floor(Math.random() * 50) + 30}
                  </span>
                  <span style={{
                    fontSize: theme.fontSize.sm,
                    color: theme.colors.textTertiary
                  }}>
                    |
                  </span>
                  <span style={{
                    fontSize: theme.fontSize.sm,
                    color: theme.colors.textSecondary
                  }}>
                    距离 {(Math.random() * 2 + 0.5).toFixed(1)}km
                  </span>
                </div>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.textTertiary,
                  display: 'flex',
                  alignItems: 'center'
                }}>
                  📍 {shop.address}
                </p>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  )
}

export default HomePage