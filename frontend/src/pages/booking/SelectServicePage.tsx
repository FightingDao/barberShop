import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Loading, Button, Popup, Notify } from 'react-vant'
import { InfoO, Success } from '@react-vant/icons'
import { useAppDispatch, useAppSelector } from '@/store'
import { fetchShopServicesAsync } from '@/store/slices/shopsSlice'
import { setService } from '@/store/slices/bookingSlice'
import { Service } from '@/types'
import { theme, commonStyles } from '@/styles/theme'

const SelectServicePage: React.FC = () => {
  const { shopId } = useParams()
  const navigate = useNavigate()
  const dispatch = useAppDispatch()
  const { services, isLoading } = useAppSelector(state => state.shops)
  const { shop } = useAppSelector(state => state.booking)

  const [selectedService, setSelectedService] = useState<Service | null>(null)
  const [showDetail, setShowDetail] = useState(false)
  const [detailService, setDetailService] = useState<Service | null>(null)

  useEffect(() => {
    if (shopId) {
      dispatch(fetchShopServicesAsync(Number(shopId)))
    }
  }, [shopId, dispatch])

  const handleSelectService = (service: Service) => {
    // 单选机制：点击已选中的服务取消选中
    if (selectedService?.id === service.id) {
      setSelectedService(null)
    } else {
      setSelectedService(service)
    }
  }

  const handleShowDetail = (e: React.MouseEvent, service: Service) => {
    e.stopPropagation() // 阻止冒泡，避免触发卡片选中
    setDetailService(service)
    setShowDetail(true)
  }

  const handleNext = () => {
    if (!selectedService) {
      Notify.show({ type: 'warning', message: '请选择服务项目' })
      return
    }

    dispatch(setService(selectedService))
    Notify.show({ type: 'success', message: `已选择：${selectedService.name}` })
    navigate(`/booking/select-stylist/${shopId}`)
  }

  if (isLoading) {
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
      paddingBottom: '100px'
    }}>
      {/* 自定义顶部导航 */}
      <div style={{
        position: 'sticky',
        top: 0,
        zIndex: 100,
        background: theme.colors.bgPrimary,
        boxShadow: theme.shadows.small,
        padding: `${theme.spacing.md} ${theme.spacing.lg}`,
        display: 'flex',
        alignItems: 'center'
      }}>
        <div
          onClick={() => navigate(-1)}
          style={{
            width: '32px',
            height: '32px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: theme.colors.bgSecondary,
            borderRadius: theme.borderRadius.round,
            cursor: 'pointer',
            marginRight: theme.spacing.md
          }}
        >
          <span style={{ fontSize: '18px' }}>←</span>
        </div>
        <h2 style={{
          margin: 0,
          fontSize: theme.fontSize.lg,
          fontWeight: 'bold',
          color: theme.colors.textPrimary
        }}>
          选择服务
        </h2>
      </div>

      <div style={{ padding: theme.spacing.lg }}>
        {/* 店铺信息 */}
        <div style={{
          ...commonStyles.card,
          marginBottom: theme.spacing.lg,
          background: theme.colors.primaryLight
        }}>
          <h3 style={{
            margin: 0,
            fontSize: theme.fontSize.lg,
            color: theme.colors.primary,
            fontWeight: 'bold'
          }}>
            {shop?.name}
          </h3>
          <p style={{
            margin: `${theme.spacing.sm} 0 0 0`,
            fontSize: theme.fontSize.sm,
            color: theme.colors.textSecondary
          }}>
            请选择需要的服务
          </p>
        </div>

        {services.length === 0 ? (
          <div style={commonStyles.empty}>
            <div style={{
              fontSize: '48px',
              marginBottom: theme.spacing.md,
              color: theme.colors.textTertiary
            }}>
              ✂️
            </div>
            <p style={{
              margin: 0,
              fontSize: theme.fontSize.base,
              color: theme.colors.textTertiary
            }}>
              暂无服务
            </p>
          </div>
        ) : (
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: theme.spacing.lg
          }}>
            {services.map(service => {
              const isSelected = selectedService?.id === service.id
              return (
                <div
                  key={service.id}
                  onClick={() => handleSelectService(service)}
                  style={{
                    position: 'relative',
                    padding: theme.spacing.lg,
                    background: isSelected ? theme.colors.primaryLight : theme.colors.bgPrimary,
                    borderRadius: theme.borderRadius.medium,
                    border: isSelected ? `2px solid ${theme.colors.primary}` : `1px solid ${theme.colors.borderLight}`,
                    cursor: 'pointer',
                    transition: 'all 0.3s ease',
                    transform: isSelected ? 'scale(0.98)' : 'scale(1)',
                    boxShadow: isSelected ? theme.shadows.primary : theme.shadows.small
                  }}
                >
                  {/* 选中标记 */}
                  {isSelected && (
                    <div style={{
                      position: 'absolute',
                      top: theme.spacing.md,
                      right: theme.spacing.md,
                      width: '28px',
                      height: '28px',
                      borderRadius: theme.borderRadius.round,
                      background: theme.colors.primary,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      boxShadow: theme.shadows.medium
                    }}>
                      <Success style={{ color: theme.colors.bgPrimary, fontSize: '16px' }} />
                    </div>
                  )}

                  <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    {/* 服务图标 */}
                    <div style={{
                      width: '60px',
                      height: '60px',
                      borderRadius: theme.borderRadius.medium,
                      background: isSelected ? theme.colors.primary : theme.colors.bgTertiary,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '28px',
                      marginRight: theme.spacing.lg,
                      transition: 'all 0.3s ease'
                    }}>
                      ✂️
                    </div>

                    {/* 服务信息 */}
                    <div style={{ flex: 1 }}>
                      <h4 style={{
                        margin: `0 0 ${theme.spacing.sm} 0`,
                        fontSize: theme.fontSize.lg,
                        fontWeight: 'bold',
                        color: theme.colors.textPrimary
                      }}>
                        {service.name}
                      </h4>
                      {service.description && (
                        <p style={{
                          margin: `0 0 ${theme.spacing.sm} 0`,
                          fontSize: theme.fontSize.sm,
                          color: theme.colors.textSecondary,
                          lineHeight: '1.5'
                        }}>
                          {service.description.length > 30
                            ? service.description.substring(0, 30) + '...'
                            : service.description}
                        </p>
                      )}
                      <div style={{
                        display: 'flex',
                        gap: theme.spacing.md,
                        fontSize: theme.fontSize.sm,
                        color: theme.colors.textTertiary
                      }}>
                        <span>⏱ {service.duration}分钟</span>
                      </div>
                    </div>

                    {/* 价格和详情按钮 */}
                    <div style={{
                      textAlign: 'right',
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'flex-end',
                      gap: theme.spacing.sm
                    }}>
                      <div style={{
                        fontSize: theme.fontSize.xl,
                        fontWeight: 'bold',
                        color: theme.colors.primary
                      }}>
                        ¥{service.price}
                      </div>
                      <div
                        onClick={(e) => handleShowDetail(e, service)}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: theme.spacing.xs,
                          fontSize: theme.fontSize.sm,
                          color: theme.colors.primary,
                          padding: `${theme.spacing.xs} ${theme.spacing.sm}`,
                          borderRadius: theme.borderRadius.small,
                          background: theme.colors.primaryLight,
                          cursor: 'pointer',
                          transition: 'all 0.2s ease'
                        }}
                      >
                        <InfoO style={{ fontSize: '14px' }} />
                        详情
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* 底部操作栏 */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        padding: theme.spacing.lg,
        background: theme.colors.bgPrimary,
        borderTop: `1px solid ${theme.colors.borderLight}`,
        boxShadow: theme.shadows.large
      }}>
        <div style={{
          marginBottom: theme.spacing.md,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center'
        }}>
          <span style={{
            fontSize: theme.fontSize.base,
            color: theme.colors.textSecondary
          }}>
            {selectedService ? `已选：${selectedService.name}` : '请选择服务'}
          </span>
          {selectedService && (
            <span style={{
              fontSize: theme.fontSize.xl,
              fontWeight: 'bold',
              color: theme.colors.primary
            }}>
              ¥{selectedService.price}
            </span>
          )}
        </div>
        <Button
          block
          round
          disabled={!selectedService}
          onClick={handleNext}
          style={{
            ...commonStyles.primaryButton,
            opacity: selectedService ? 1 : 0.6,
            cursor: selectedService ? 'pointer' : 'not-allowed'
          }}
        >
          下一步
        </Button>
      </div>

      {/* 服务详情弹窗 */}
      <Popup
        visible={showDetail}
        onClose={() => setShowDetail(false)}
        position="bottom"
        round
        style={{ height: '60%' }}
      >
        {detailService && (
          <div style={{ padding: theme.spacing.xxl }}>
            <h2 style={{
              margin: `0 0 ${theme.spacing.lg} 0`,
              fontSize: theme.fontSize.huge,
              color: theme.colors.textPrimary,
              fontWeight: 'bold'
            }}>
              {detailService.name}
            </h2>

            <div style={{
              marginBottom: theme.spacing.xxl,
              ...commonStyles.card
            }}>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                marginBottom: theme.spacing.lg
              }}>
                <span style={{
                  fontSize: theme.fontSize.base,
                  color: theme.colors.textTertiary
                }}>
                  服务价格
                </span>
                <span style={{
                  fontSize: theme.fontSize.huge,
                  fontWeight: 'bold',
                  color: theme.colors.primary
                }}>
                  ¥{detailService.price}
                </span>
              </div>
              <div style={{
                display: 'flex',
                justifyContent: 'space-between'
              }}>
                <span style={{
                  fontSize: theme.fontSize.base,
                  color: theme.colors.textTertiary
                }}>
                  服务时长
                </span>
                <span style={{
                  fontSize: theme.fontSize.md,
                  fontWeight: 'bold',
                  color: theme.colors.textPrimary
                }}>
                  约 {detailService.duration} 分钟
                </span>
              </div>
            </div>

            {detailService.description && (
              <div style={{ marginBottom: theme.spacing.xxl }}>
                <h3 style={{
                  margin: `0 0 ${theme.spacing.md} 0`,
                  fontSize: theme.fontSize.lg,
                  color: theme.colors.textPrimary,
                  fontWeight: 'bold'
                }}>
                  服务说明
                </h3>
                <p style={{
                  margin: 0,
                  fontSize: theme.fontSize.base,
                  color: theme.colors.textSecondary,
                  lineHeight: '1.8'
                }}>
                  {detailService.description}
                </p>
              </div>
            )}

            <div style={{ marginBottom: theme.spacing.xxl }}>
              <h3 style={{
                margin: `0 0 ${theme.spacing.md} 0`,
                fontSize: theme.fontSize.lg,
                color: theme.colors.textPrimary,
                fontWeight: 'bold'
              }}>
                适用人群
              </h3>
              <p style={{
                margin: 0,
                fontSize: theme.fontSize.base,
                color: theme.colors.textSecondary,
                lineHeight: '1.8'
              }}>
                适合所有需要{detailService.name}服务的顾客
              </p>
            </div>

            <Button
              block
              round
              onClick={() => setShowDetail(false)}
              style={commonStyles.primaryButton}
            >
              知道了
            </Button>
          </div>
        )}
      </Popup>
    </div>
  )
}

export default SelectServicePage
