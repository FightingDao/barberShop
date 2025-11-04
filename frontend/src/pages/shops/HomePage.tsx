import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Card, Loading, Empty, Search } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopsAsync } from '@/store/slices/shopsSlice'
import { theme, commonStyles } from '@/styles/theme'
import shopImg from '@/assets/shop.jpeg'
import { useDebouncedCallback } from '@/hooks/useDebounce'

const HomePage: React.FC = () => {
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { shops, isLoading } = useAppSelector(state => state.shops)

  // 搜索关键字状态
  const [searchValue, setSearchValue] = useState('')

  // 防抖处理搜索
  const handleSearch = useDebouncedCallback((value: string) => {
    // 如果搜索框为空，不传 search 参数，这样后端会返回所有店铺
    if (!value.trim()) {
      dispatch(fetchShopsAsync())
    } else {
      dispatch(fetchShopsAsync({ search: value.trim() }))
    }
  }, 500)

  // 处理搜索输入
  const handleSearchChange = (value: string) => {
    setSearchValue(value)
    handleSearch(value)
  }

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
    <div style={{
        ...commonStyles.container,
        padding: 0,
        paddingTop: '60px', // 为固定头部留出空间
        backgroundColor: theme.colors.bgPrimary
      }}>
      {/* Header */}
      <div style={{
        background: theme.colors.bgPrimary,
        padding: `${theme.spacing.lg} ${theme.spacing.lg}`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 100,
        boxShadow: theme.shadows.small,
        height: '60px'
      }}>
        <h1 style={{
          fontSize: theme.fontSize.xl,
          fontWeight: 'bold',
          margin: 0,
          color: theme.colors.textPrimary
        }}>
          发现好店
        </h1>
        <div 
          onClick={() => navigate('/profile')}
          style={{
            width: '36px',
            height: '36px',
            borderRadius: theme.borderRadius.round,
            background: theme.colors.bgSecondary,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer'
          }}
        >
          <span style={{ fontSize: '18px', color: theme.colors.textSecondary }}>👤</span>
        </div>
      </div>

      {/* Search Bar */}
      <div style={{
        padding: `${theme.spacing.lg} ${theme.spacing.lg}`,
        marginBottom: theme.spacing.lg
      }}>
        <Search
          value={searchValue}
          placeholder="搜索理发店名称"
          shape="round"
          background={theme.colors.bgSecondary}
          onChange={handleSearchChange}
          style={{
            padding: 0,
            borderRadius: theme.borderRadius.large,
            overflow: 'hidden'
          }}
        />
      </div>

      {/* Shop List */}
      <div style={{ 
        padding: `0 ${theme.spacing.lg}`,
        display: 'grid',
        gap: theme.spacing.lg,
        gridTemplateColumns: '1fr'
      }}>
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
                cursor: 'pointer',
                borderRadius: theme.borderRadius.large,
                boxShadow: theme.shadows.medium,
                padding: 0,
                overflow: 'hidden',
                border: 'none',
                background: theme.colors.bgPrimary
              }}
            >
              {/* 店铺大图 */}
              <div style={{
                width: '100%',
                height: '160px',
                background: theme.colors.bgTertiary,
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
                  background: 'rgba(82, 196, 26, 0.9)',
                  color: theme.colors.bgPrimary,
                  padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                  borderRadius: theme.borderRadius.large,
                  fontSize: theme.fontSize.xs,
                  fontWeight: 'bold'
                }}>
                  营业中
                </div>

                {/* 收藏按钮 */}
                <div style={{
                  position: 'absolute',
                  top: theme.spacing.md,
                  right: theme.spacing.md,
                  width: '32px',
                  height: '32px',
                  background: 'rgba(255, 255, 255, 0.9)',
                  borderRadius: theme.borderRadius.round,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  backdropFilter: 'blur(4px)'
                }}>
                  <span style={{ fontSize: '16px', color: theme.colors.textTertiary }}>🤍</span>
                </div>
              </div>

              {/* 店铺信息 */}
              <div style={{ padding: theme.spacing.lg }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  marginBottom: theme.spacing.sm
                }}>
                  <h3 style={{
                    margin: 0,
                    fontSize: theme.fontSize.lg,
                    fontWeight: 'bold',
                    color: theme.colors.textPrimary,
                    flex: 1,
                    paddingRight: theme.spacing.sm
                  }}>
                    {shop.name}
                  </h3>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    background: theme.colors.primaryLight,
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                    borderRadius: theme.borderRadius.large
                  }}>
                    <span style={{
                      color: theme.colors.primary,
                      fontSize: theme.fontSize.sm,
                      marginRight: theme.spacing.xs,
                      fontWeight: 'bold'
                    }}>
                      4.8
                    </span>
                    <span style={{
                      color: theme.colors.primary,
                      fontSize: theme.fontSize.sm
                    }}>
                      分
                    </span>
                  </div>
                </div>

                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: theme.spacing.md,
                  marginBottom: theme.spacing.md
                }}>
                  <span style={{
                    fontSize: theme.fontSize.sm,
                    color: theme.colors.primary,
                    background: theme.colors.primaryLight,
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                    borderRadius: theme.borderRadius.large,
                  }}>
                    人均 ¥{Math.floor(Math.random() * 50) + 30}
                  </span>
                  <span style={{
                    fontSize: theme.fontSize.sm,
                    color: theme.colors.textSecondary,
                    background: theme.colors.bgSecondary,
                    padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                    borderRadius: theme.borderRadius.large,
                  }}>
                    {(Math.random() * 2 + 0.5).toFixed(1)}km
                  </span>
                </div>

                <div style={{
                  margin: 0,
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.textTertiary,
                  display: 'flex',
                  alignItems: 'flex-start',
                  gap: theme.spacing.xs
                }}>
                  <span style={{ marginTop: '2px' }}>📍</span>
                  <span style={{ flex: 1, lineHeight: 1.5 }}>{shop.address}</span>
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