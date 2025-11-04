import React, { useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Button, Loading, NavBar } from 'react-vant'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopDetailAsync } from '@/store/slices/shopsSlice'
import { setShop } from '@/store/slices/bookingSlice'
import { theme, commonStyles } from '@/styles/theme'
import shopImg from '@/assets/shop.jpeg'

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
    return (
      <div style={commonStyles.loadingCenter}>
        <Loading size="24px" color={theme.colors.primary} />
      </div>
    )
  }

  return (
    <div style={{
      background: theme.colors.bgSecondary,
      minHeight: '100vh',
      paddingBottom: '90px'  // 为底部按钮留出空间
    }}>
      {/* 顶部导航 - 固定在顶部 */}
      <NavBar
        title="店铺详情"
        leftText=""
        onClickLeft={() => navigate(-1)}
        style={{
          background: theme.colors.bgPrimary,
          boxShadow: theme.shadows.small,
          position: 'sticky',
          top: 0,
          zIndex: 100
        }}
        renderLeft={
          <div style={{
            width: '32px',
            height: '32px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: theme.colors.bgSecondary,
            borderRadius: theme.borderRadius.round
          }}>
            <span style={{ fontSize: '18px' }}>←</span>
          </div>
        }
        renderRight={
          <div style={{ display: 'flex', gap: theme.spacing.sm }}>
            <div style={{
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: theme.colors.bgSecondary,
              borderRadius: theme.borderRadius.round,
              cursor: 'pointer'
            }}>
              <span style={{ fontSize: '16px' }}>🔗</span>
            </div>
            <div style={{
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: theme.colors.bgSecondary,
              borderRadius: theme.borderRadius.round,
              cursor: 'pointer'
            }}>
              <span style={{ fontSize: '16px' }}>🤍</span>
            </div>
          </div>
        }
      />

      {/* 店铺大图 */}
      <div style={{
        width: '100%',
        height: '250px',
        background: '#e0e0e0',
        position: 'relative'
      }}>
        {currentShop.avatarUrl ? (
          <img
            src={shopImg || currentShop.avatarUrl}
            alt={currentShop.name}
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
            <span style={{ fontSize: '64px' }}>💈</span>
          </div>
        )}
      </div>

      {/* 店铺信息 */}
      <div style={{
        background: theme.colors.bgPrimary,
        borderRadius: `${theme.borderRadius.large} ${theme.borderRadius.large} 0 0`,
        marginTop: `-${theme.borderRadius.large}`,
        padding: theme.spacing.lg,
        paddingTop: theme.spacing.xxl
      }}>
        {/* 店铺名称和评分 */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: theme.spacing.md
        }}>
          <h2 style={{
            margin: 0,
            fontSize: theme.fontSize.huge,
            fontWeight: 'bold',
            color: theme.colors.textPrimary
          }}>
            {currentShop.name}
          </h2>
          <div style={{
            background: theme.colors.primaryLight,
            padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
            borderRadius: theme.borderRadius.small,
            color: theme.colors.primary,
            fontSize: theme.fontSize.sm,
            fontWeight: 'bold'
          }}>
            营业中
          </div>
        </div>

        {/* 评分和价格 */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: theme.spacing.lg,
          marginBottom: theme.spacing.lg
        }}>
          <div style={{ display: 'flex', alignItems: 'center' }}>
            <span style={{
              color: theme.colors.star,
              fontSize: theme.fontSize.md,
              marginRight: theme.spacing.xs
            }}>
              ⭐
            </span>
            <span style={{
              fontSize: theme.fontSize.md,
              color: theme.colors.textSecondary,
              fontWeight: 'bold'
            }}>
              4.8分
            </span>
          </div>
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
            已售{Math.floor(Math.random() * 1000) + 500}
          </span>
        </div>

        {/* 位置信息 */}
        <div style={{
          background: theme.colors.bgSecondary,
          borderRadius: theme.borderRadius.medium,
          padding: theme.spacing.lg,
          marginBottom: theme.spacing.lg
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'flex-start',
            marginBottom: theme.spacing.md
          }}>
            <span style={{ fontSize: '18px', marginRight: theme.spacing.sm, marginTop: '2px' }}>📍</span>
            <div style={{ flex: 1 }}>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.base,
                color: theme.colors.textPrimary,
                marginBottom: theme.spacing.xs
              }}>
                {currentShop.address}
              </p>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.sm,
                color: theme.colors.textTertiary
              }}>
                距离您 {(Math.random() * 2 + 0.5).toFixed(1)}km
              </p>
            </div>
          </div>

          <div style={{
            display: 'flex',
            alignItems: 'center'
          }}>
            <span style={{ fontSize: '18px', marginRight: theme.spacing.sm }}>🕐</span>
            <div>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.base,
                color: theme.colors.textPrimary,
                marginBottom: theme.spacing.xs
              }}>
                营业时间
              </p>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.sm,
                color: theme.colors.textTertiary
              }}>
                {new Date(currentShop.openingTime).toLocaleTimeString('zh-CN', {hour: '2-digit', minute: '2-digit'})} - {new Date(currentShop.closingTime).toLocaleTimeString('zh-CN', {hour: '2-digit', minute: '2-digit'})}
              </p>
            </div>
          </div>
        </div>

        {/* 服务项目 */}
        <div style={{ marginBottom: theme.spacing.lg }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.lg,
            fontWeight: 'bold',
            color: theme.colors.textPrimary
          }}>
            服务项目
          </h3>
          <div style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: theme.spacing.md
          }}>
            {['男士洗剪吹', '女士造型', '染发服务', '烫发服务'].map((service, index) => (
              <div key={index} style={{
                background: theme.colors.bgSecondary,
                borderRadius: theme.borderRadius.medium,
                padding: theme.spacing.md,
                textAlign: 'center'
              }}>
                <div style={{
                  width: '40px',
                  height: '40px',
                  background: theme.colors.primaryLight,
                  borderRadius: theme.borderRadius.round,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: `0 auto ${theme.spacing.sm} auto`
                }}>
                  <span style={{ fontSize: '20px' }}>✂️</span>
                </div>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.textPrimary,
                  fontWeight: 'bold'
                }}>
                  {service}
                </p>
                <p style={{
                  margin: `${theme.spacing.xs} 0 0 0`,
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.primary,
                  fontWeight: 'bold'
                }}>
                  ¥{Math.floor(Math.random() * 100) + 50}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* 理发师团队 */}
        <div style={{ marginBottom: theme.spacing.xxl }}>
          <h3 style={{
            margin: `0 0 ${theme.spacing.md} 0`,
            fontSize: theme.fontSize.lg,
            fontWeight: 'bold',
            color: theme.colors.textPrimary
          }}>
            理发师团队
          </h3>
          <div style={{
            display: 'flex',
            gap: theme.spacing.lg,
            overflowX: 'auto'
          }}>
            {['张师傅', '李总监', '王设计师'].map((stylist, index) => (
              <div key={index} style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                minWidth: '80px'
              }}>
                <div style={{
                  width: '60px',
                  height: '60px',
                  borderRadius: theme.borderRadius.round,
                  background: theme.colors.bgTertiary,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginBottom: theme.spacing.sm
                }}>
                  <span style={{ fontSize: '24px' }}>👨‍💼</span>
                </div>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.sm,
                  color: theme.colors.textPrimary,
                  fontWeight: 'bold'
                }}>
                  {stylist}
                </p>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.xs,
                  color: theme.colors.textTertiary
                }}>
                  {index === 0 ? '5年经验' : index === 1 ? '8年经验' : '3年经验'}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 底部预约按钮 - 固定在底部 */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        background: theme.colors.bgPrimary,
        padding: theme.spacing.lg,
        boxShadow: theme.shadows.large,
        zIndex: 99,
        borderTop: `1px solid ${theme.colors.borderLight}`
      }}>
        <Button
          block
          round
          onClick={handleBooking}
          style={{
            ...commonStyles.primaryButton,
            height: '52px',
            fontSize: theme.fontSize.xl
          }}
        >
          立即预约
        </Button>
      </div>
    </div>
  )
}

export default ShopDetailPage